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
  let(:redis) { MockRedis.new }
  let(:harvester) { Harvester.new(redis) }

  context "#run" do
    it "connects to the twitter streaming api" do
      fake_stream = FakeStream.new
      harvester.stub(:create_stream).and_return(fake_stream)
      harvester.should_receive(:create_stream)
      harvester.run
    end
  end
end
