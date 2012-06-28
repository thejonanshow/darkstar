$LOAD_PATH.unshift('./', './lib', './config').uniq!
require 'fog'
require 'drone'
require 'harvester'
require 'secret/aws_credentials'

class Mothership
  attr_reader :drones, :connection, :servers, :available_credentials, :used_credentials

  def initialize(ansible = Ansible.new)
    @connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_access_key_id => AWS_ACCESS_KEY_ID,
      :aws_secret_access_key => AWS_SECRET_ACCESS_KEY
    })
    @ansible = ansible
    @available_credentials = []
    @used_credentials = []
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

  def add_credentials(credential)
    @available_credentials << credential
  end

  def get_credentials
    credential = @available_credentials.pop
    @used_credentials << credential
    credential
  end

  def load_credentials(filename)
    @available_credentials += Marshal.load(File.read(filename))
  end

  def send_credential_to(id)
    @ansible.send_credential({id => get_credentials}.to_json)
  end
end
