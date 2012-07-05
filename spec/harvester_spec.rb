require 'spec_helper'
require 'harvester'
require 'mock_redis'
require 'twitter/json_stream'

class FakeStream
  %w[connect each_item on_error on_max_reconnects on_no_data].each do |meth|
    define_method(meth.to_sym) { EventMachine.next_tick { EventMachine.stop } }
  end
end

describe Harvester do
  let(:ansible) { Ansible.new(MockRedis.new) }
  let(:harvester) { Harvester.new(:ansible => ansible) }

  it "requests credentials from home on initialization" do
    msg = {:method => 'send_credentials'}
    ansible.should_receive(:send_home_and_wait).with(msg, 'credentials')
    Harvester.new(:ansible => ansible)
  end

  it "sets the default stream to sample" do
    harvester.should_receive(:create_stream) do |options|
      options[:path].should == '/1/statuses/sample.json'
    end.and_return(FakeStream.new)
    harvester.call
  end

  context "#call" do
    it "connects to the twitter streaming api" do
      fake_stream = FakeStream.new
      harvester.stub(:create_stream).and_return(fake_stream)
      harvester.should_receive(:create_stream)
      harvester.call
    end
  end
end
