$LOAD_PATH.unshift('./', './lib', './config').uniq!
require 'fog'
require 'drone'
require 'harvester'
require 'secret/aws_credentials'

class Mothership
  attr_reader :drones, :connection, :servers, :available_credentials

  def initialize
    @connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_access_key_id => AWS_ACCESS_KEY_ID,
      :aws_secret_access_key => AWS_SECRET_ACCESS_KEY
    })
    @available_credentials = []
    @servers = @connection.servers
    @drones = @servers.map do |srv|
      Drone.new(srv) if %w[running pending].include? srv.state
    end.compact
    @drones.map { |drone| drone.mothership = self }
  end

  def spawn_drone(server = nil)
    server ||= spawn_server
    Drone.new(server).tap { |drn| @drones << drn; drn.mothership = self }
  end

  def spawn_server
    server = connection.servers.create(
      :image_id => 'ami-0e7ad867',
      :private_key_path => './config/secret/fog_default'
    ).tap { |srv| @servers << srv }
  end

  def get_credentials
    @available_credentials.pop
  end

  def used_credentials
    @drones.map(&:used_credentials).flatten
  end

  def load_credentials(filename)
    @available_credentials += Marshal.load(File.read(filename))
  end
end
