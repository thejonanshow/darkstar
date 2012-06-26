require 'spec_helper'
require 'mothership'

describe Mothership do
  before(:each) do
    Fog.mock!
  end

  let(:mothership) { Mothership.new }

  it "initiates an AWS connection on instantiation" do
    Fog::Compute.should_receive(:new).with(
      hash_including(
        :provider,
        :aws_access_key_id,
        :aws_secret_access_key
      )
    )
    Mothership.new
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

    it "sets a time to live on the server with a 55 minute default"
  end
end
