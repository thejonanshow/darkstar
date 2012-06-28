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

  it "requests credentials for an id on redis"
  
  context "#get_credentials" do
    it "gets credentials"
  end
  context "#sends_credentials" do
    it "gets credentials"
  end
  context "#sends_messages" do
    it "gets credentials"
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
