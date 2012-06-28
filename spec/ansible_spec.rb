require 'spec_helper'
require 'ansible'
require 'redis'
require 'mock_redis'

describe Ansible do
  let(:redis) { MockRedis.new }
  let(:ansible) { Ansible.new(redis) }

  it "sets a given value in redis" do
    redis.should_receive(:set).with('a', 1)
    ansible.set('a', 1)
  end

  it "authorizes if an 'operation not permitted' error is raised by redis" do
    redis.should_receive(:auth)
    redis.should_receive(:set).once.and_raise(Redis::CommandError.new('ERR operation not permitted'))
    redis.should_receive(:set).and_return("OK")
    ansible.set('a', 1)
  end

  it "raises errors other than 'operation not permitted'" do
    redis.should_receive(:set).once.and_raise(Redis::CommandError.new('ERR Client sent AUTH, but no password is set'))
    redis.should_not_receive(:auth)
    expect { ansible.set('a', 1) }.to raise_error Redis::CommandError
  end

  context "#send_home" do
    it "publishes a message to the mothership_id" do
      redis.set('mothership_id', '1')
      msg = {:method => 'send_credentials'}
      home_msg = msg.tap { |m| m[:to] = '1'; m[:from] = ansible.id }
      redis.should_receive(:publish).with('mothership', home_msg.to_json)
      ansible.send_home(msg)
    end
  end

  context "#send_home_and_wait" do
    it "publishes a message to the mothership_id and blocks until it receives a response" do
      redis.set('mothership_id', '1')
      msg = {:method => 'send_credentials'}
      home_msg = msg.tap { |m| m[:to] = '1'; m[:from] = ansible.id }
      redis.should_receive(:publish).with('mothership', home_msg.to_json)
      redis.should_receive(:psubscribe).with('*')
      ansible.send_home_and_wait(msg, 'credentials')
    end
  end

  context "#send_message" do
    it "sends a message from the ansible id" do
      msg = {:from => ansible.id, :method => 'send_credentials'}
      redis.should_receive(:publish).with('darkstar', msg.to_json)
      ansible.send_message(msg)
    end

    it "optionally accepts a target id" do
      msg = {:to => '1', :from => ansible.id, :method => 'send_credentials'}
      redis.should_receive(:publish).with('darkstar', msg.to_json)
      ansible.send_message(msg, '1')
    end
  end

  context "#send_and_wait" do
    it "sends a message and blocks until it receives a response" do
      msg = {:from => ansible.id, :method => 'send_credentials'}
      redis.should_receive(:publish).with('darkstar', msg.to_json)
      redis.should_receive(:psubscribe).with('*')
      ansible.send_and_wait(msg, 'credentials')
    end
  end

  context "com_link" do
    it "creates a com_link thread when instantiated" do
      ansible.com_link.should_not be_nil
    end

    it "uses the redis from ansible" do
      ansible.redis.should == ansible.com.redis
    end
  end
end
