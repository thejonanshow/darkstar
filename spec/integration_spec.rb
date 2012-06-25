require 'spec_helper'
require 'mock_redis'
require 'mothership'
require 'drone'
require 'harvester'

describe Mothership do
  before(:each) do
    Fog.mock!
  end

  it "uploads a new payload to the server on implant" do
    mothership = Mothership.new
    drone = mothership.spawn_drone
    drone.server.public_ip_address = '127.0.0.1'
    drone.server.stub(:ssh)
    drone.server.stub(:ready?).and_return(true)
    drone.server.should_receive(:scp).with("lib/harvester.rb", "harvester.rb")
    drone.implant(Harvester.new(MockRedis.new))
  end

  it "activates a new payload on implant" do
    mothership = Mothership.new
    drone = mothership.spawn_drone
    drone.server.public_ip_address = '127.0.0.1'
    drone.server.stub(:scp)
    drone.server.should_receive(:ssh).with("implant.sh harvester.rb")
    drone.implant(Harvester.new(MockRedis.new))
  end
end
