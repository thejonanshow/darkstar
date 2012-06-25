require 'fog'
require 'drone'

class Mothership
  attr_reader :drones, :connection, :servers

  def initialize
    @servers = []
    @drones = []
    @connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_access_key_id => 'abc',
      :aws_secret_access_key => '123'
    })
  end

  def spawn_drone
    drone = Drone.new(spawn_server).tap { |drn| @drones << drn }
  end

  def spawn_server
    server = connection.servers.create(
      :image_id => 'ami-0e7ad867',
      :private_key_path => './config/secret/fog_default'
    ).tap { |srv| @servers << srv }
  end
end
