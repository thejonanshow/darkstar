require 'spec_helper'
require 'mock_redis'
require 'mothership'
require 'drone'
require 'harvester'

describe Mothership do
  before(:each) do
    Fog.mock!
  end

  let(:ansible) { Ansible.new(MockRedis.new) }

  it "uploads a new payload to the server on implant" do
    mothership = Mothership.new
    drone = mothership.spawn_drone
    drone.should_receive(:build_implant_file)
    drone.server.public_ip_address = '127.0.0.1'
    drone.server.should_receive(:ready?).and_return(true)
    drone.server.should_receive(:scp).with("implants/harvester.implant", "harvester.rb")
    drone.server.should_receive(:ssh).with("implant.sh harvester.rb")
    drone.implant(Harvester.new(:ansible => ansible))
  end

  it "activates a new payload on implant" do
    mothership = Mothership.new
    drone = mothership.spawn_drone
    drone.should_receive(:build_implant_file)
    drone.server.public_ip_address = '127.0.0.1'
    drone.server.stub(:scp)
    drone.server.should_receive(:ssh).with("implant.sh harvester.rb")
    drone.implant(Harvester.new(:ansible => ansible))
  end
end
