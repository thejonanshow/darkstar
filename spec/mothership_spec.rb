require 'spec_helper'
require 'mothership'

describe Mothership do
  before(:each) do
    Fog.mock!
  end

  let(:mothership) { Mothership.new }

  it "initiates an AWS connection on instantiation" do
    mothership.connection.should_not be_nil
  end

  context "#spawn_drone" do
    it "adds a new drone to it's drones" do
      expect { mothership.spawn_drone }.to change { mothership.drones.length }.by(1)
    end

    it "creates a drone with a server" do
      mothership.spawn_drone.server.should_not be_nil
    end
  end

  context "#spawn_server" do
    it "creates a new server in servers" do
      expect { mothership.spawn_server }.to change { mothership.servers.length }.by(1)
    end
  end

  context "#used_credentials" do
    it "returns all credentials currently in use" do
      credential = { :login => 'foo', :password => 'bar' }
      mothership.available_credentials << credential
      mothership.spawn_drone.implant(Harvester.new(:ansible => Ansible.new))
      mothership.available_credentials.should_not include credential
      mothership.used_credentials.should include(credential)
    end
  end

  context "#load_credentials" do
    it "loads credentials from a file" do
      credential = { :login => 'foo', :password => 'bar' }
      File.write('spec/fixtures/test.dmp', Marshal.dump([credential]))
      mothership.available_credentials.should_not include credential
      mothership.load_credentials('spec/fixtures/test.dmp')
      mothership.available_credentials.should include credential
    end
  end
end
