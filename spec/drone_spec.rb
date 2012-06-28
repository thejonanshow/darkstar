require 'spec_helper'
require 'drone'
require 'timecop'

class Payload
  attr_accessor :credentials
  # the class name is used to derive the filename
end

class FakeMothership
end

describe Drone do
  let(:drone) { Drone.new(double(:server)).tap {|d| d.mothership = FakeMothership.new } }
  let(:payload) { Payload.new }

  it "accepts a server argument" do
    expect { Drone.new(double(:server)) }.not_to raise_error ArgumentError
  end

  it "raises an argument error without a server" do
    expect { Drone.new }.to raise_error ArgumentError
  end

  context "#implant" do
    it "uploads the file to the server" do
      drone.server.stub(:ssh)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:scp).with('implants/payload.implant', 'payload.rb')
      drone.implant(payload)
    end

    it "should call the implant script on the uploaded file" do
      drone.server.stub(:scp)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:ssh).with("implant.sh payload.rb")
      drone.implant(payload)
    end

    it "raises an implant timeout error on timeout" do
      drone.stub(:wait_for_server)
      drone.server.should_receive(:scp) { sleep 3 }
      Timecop.freeze(Time.now + 10) do
        expect { drone.implant(payload, 0, 0.0001) }.to raise_error ImplantTimeout
      end
    end

    it "is included in the drone's implants" do
      drone.server.stub(:ssh)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:scp).with('implants/payload.implant', 'payload.rb')
      expect { drone.implant(payload) }.to change { drone.implants.count }.by(1)
    end
  end
end
