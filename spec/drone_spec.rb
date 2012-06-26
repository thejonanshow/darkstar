require 'spec_helper'
require 'drone'
require 'timecop'

class Payload
  # the class name is used to derive the filename
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

    it "raises an implant timeout error on timeout" do
      drone.stub(:wait_for_server)
      drone.server.should_receive(:scp) { sleep 3 }
      Timecop.freeze(Time.now + 10) do
        expect { drone.implant(payload, 0, 0.0001) }.to raise_error ImplantTimeout
      end
    end
  end
end
