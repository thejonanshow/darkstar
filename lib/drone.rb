require 'config/secret/aws_credentials'
require 'timeout'

class Drone
  attr_reader :server, :implants
  attr_writer :mothership

  def initialize(server)
    @server = server
    @implants = []
  end

  def implant(implant, tries = 5, timeout = 1)
    wait_for_server(30, timeout)
    count = 1

    begin
      Timeout.timeout timeout, ImplantTimeout do
        install(implant)
        @implants << implant
      end
    rescue ImplantTimeout => e
      count += 1
      if count <= tries
        retry
      else
        raise e
      end
    end
  end

  def wait_for_server(tries = 30, timeout = 1)
    count = 1

    begin
      Timeout.timeout timeout, ServerReadyTimeout do
        @server.wait_for { ready? }
      end
    rescue ServerReadyTimeout => e
      count += 1
      if count <= tries
        retry
      else
        raise e
      end
    end
  end

  def install(implant)
    filename = underscore(implant.class)
    build_implant_file(filename)
    @server.scp("implants/#{filename + '.implant'}", "#{filename + '.rb'}")
    @server.ssh("implant.sh #{filename + '.rb'}")
  end

  def build_implant_file(filename, source_dir = 'lib', target_dir = 'implants')
    files = [ "config/initializers/redis.rb",
              "#{source_dir}/ansible.rb",
              "#{source_dir}/#{filename}.rb"]

    implant = files.map { |f| File.read(f) }.join("\n")
    File.write("#{target_dir}/#{filename}.implant", implant)
  end

  def die!
    @server.destroy
  end

  def underscore(name)
    name = name.to_s
    name.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class ServerReadyTimeout < Timeout::Error; end
class ImplantTimeout < Timeout::Error; end
