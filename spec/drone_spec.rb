require 'spec_helper'
require 'drone'

class Payload
end

describe Drone do
  let(:drone) { Drone.new(double(:server)) }
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
      drone.server.should_receive(:scp).with('lib/payload.rb', 'payload.rb')
      drone.implant(payload)
    end

    it "should call the implant script on the uploaded file" do
      drone.server.stub(:scp)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:ssh).with("implant.sh payload.rb")
      drone.implant(payload)
    end
  end
end
