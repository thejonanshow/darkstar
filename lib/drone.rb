require 'config/secret/aws_credentials'
require 'eventmachine'

class Drone
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def implant(payload)
    @server.wait_for { ready? && @server.ssh('ls') }
    filename = underscore(payload.class) + '.rb'
    @server.scp("lib/#{filename}", "#{filename}")
    @server.ssh("implant.sh #{filename}")
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
