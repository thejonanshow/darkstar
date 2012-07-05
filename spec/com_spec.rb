require 'spec_helper'
require 'com'

describe Com do
  xit "listens to redis on all channels when called" do
    redis = MockRedis.new
    ansible = double(:ansible)
    ansible.stub(:redis).and_return(redis)
    com = Com.new(ansible)
    com.redis.should_receive(:psubscribe).with('*')
    com.call
  end

  it "listens to redis on all channels when waiting for a message" do
    redis = MockRedis.new
    ansible = double(:ansible)
    ansible.stub(:redis).and_return(redis)
    ansible.stub(:id).and_return('1')
    com = Com.new(ansible)
    com.redis.should_receive(:psubscribe).with('*')
    com.wait_for_message_with('foo')
  end

  it "identifies inbound message ownership by id" do
    caller = double(:caller)
    caller.stub(:id).and_return('1')
    caller.stub(:redis)
    parsed_message = {'to' => '1', 'body' => 'foo'}
    com = Com.new(caller)
    com.my_message?(parsed_message).should be true
  end
end
