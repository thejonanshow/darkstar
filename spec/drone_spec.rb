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
    it "builds the implant file" do
      drone.should_receive(:build_implant_file).with('payload')
      drone.server.stub(:ssh)
      drone.server.stub(:scp)
      drone.server.stub(:wait_for)
      drone.implant(payload)
    end

    it "uploads the file to the server" do
      drone.stub(:build_implant_file)
      drone.server.stub(:ssh)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:scp).with('implants/payload.implant', 'payload.rb')
      drone.implant(payload)
    end

    it "should call the implant script on the uploaded file" do
      drone.stub(:build_implant_file)
      drone.server.stub(:scp)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:ssh).with("implant.sh payload.rb")
      drone.implant(payload)
    end

    it "raises an implant timeout error on timeout" do
      drone.stub(:build_implant_file)
      drone.stub(:wait_for_server)
      drone.server.should_receive(:scp) { sleep 3 }
      Timecop.freeze(Time.now + 10) do
        expect { drone.implant(payload, 0, 0.0001) }.to raise_error ImplantTimeout
      end
    end

    it "is included in the drone's implants" do
      drone.stub(:build_implant_file)
      drone.server.stub(:ssh)
      drone.server.stub(:wait_for)
      drone.server.should_receive(:scp).with('implants/payload.implant', 'payload.rb')
      expect { drone.implant(payload) }.to change { drone.implants.count }.by(1)
    end
  end

  context "#build_implant_file" do
    after(:all) do
      %w[ansible.rb payload.rb payload.implant].map {|f| `rm spec/fixtures/#{f}`}
    end

    it "writes the implant file to the implants directory" do
      File.write('spec/fixtures/ansible.rb', 'foo')
      File.write('spec/fixtures/payload.rb', 'bar')

      drone.build_implant_file(drone.underscore(payload.class), 'spec/fixtures', 'spec/fixtures')

      File.exist?('spec/fixtures/payload.implant').should be_true
      contents = File.read('spec/fixtures/payload.implant')
      contents.should include "foo\nbar"
    end


    pending "writes the executable lines to the implant file" do
      File.write('spec/fixtures/ansible.rb', 'foo')
      File.write('spec/fixtures/payload.rb', 'bar')

      drone.build_implant_file(drone.underscore(payload.class), 'spec/fixtures', 'spec/fixtures')

      contents = File.read('spec/fixtures/payload.implant')
      contents.should include "#!/usr/bin/env ruby"
      contents.should include "Payload.new.run"
    end
  end
end
