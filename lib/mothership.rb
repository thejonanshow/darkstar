$LOAD_PATH.unshift('./', './lib', './config').uniq!
require 'fog'
require 'drone'
require 'harvester'
require 'secret/aws_credentials'

class Mothership
  attr_reader :drones, :connection, :servers

  def initialize
    @connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_access_key_id => AWS_ACCESS_KEY_ID,
      :aws_secret_access_key => AWS_SECRET_ACCESS_KEY
    })
    @servers = @connection.servers
    @drones = @servers.map do |srv|
      Drone.new(srv) if %w[running pending].include? srv.state
    end.compact
  end

  def spawn_drone(server = nil)
    server ||= spawn_server
    Drone.new(server).tap { |drn| @drones << drn }
  end

  def spawn_server
    server = connection.servers.create(
      :image_id => 'ami-0e7ad867',
      :private_key_path => './config/secret/fog_default'
    ).tap { |srv| @servers << srv }
  end
end
