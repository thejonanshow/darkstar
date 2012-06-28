require 'config/initializers/redis.rb'
require 'digest/md5'
require 'json'

class Ansible
  attr_reader :redis, :com, :com_link, :id

  def initialize(redis = REDIS)
    @id = generate_id
    @redis = redis
    @com = Com.new(self)
    @com_link = Thread.new { @com.run }
  end

  def set(key, value)
    begin
      @redis.set(key, value)
    rescue Redis::CommandError => e
      if e.message == 'ERR operation not permitted'
        @redis.auth(REDIS_PASSWORD)
        retry
      else
        raise e
      end
    end
  end

  def get_credentials
  end

  def send_credential(credential_json)
  end

  def send_message(channel, message)
    @redis.publish channel, message
  end

  def new_message(message)
    puts message
  end

  def generate_id
    Digest::MD5.hexdigest("#{Time.now.to_f}#{rand(777)}")
  end

  def wait_for_message_with(key)
    puts Com.new(self).wait_for_message_with(key)
  end
end

class Com
  attr_reader :redis

  def initialize(caller)
    @redis = caller.redis
    @caller = caller
  end

  def run
    @redis.psubscribe('*') do |on|
      on.pmessage do |pattern, channel, msg|
        @caller.new_message(msg) if my_message?(msg)
      end
    end
  end

  def wait_for_message_with(key)
    id = @caller.id
    message = nil
    @redis.psubscribe('*') do |on|
      on.pmessage do |pattern, channel, msg|
        parsed = JSON.parse(msg)
        message = parsed if my_message?(parsed) && parsed[key]
        @redis.punsubscribe('*') if message
      end
    end
    message
  end

  def my_message?(parsed_message)
    parsed_message['to'] == @caller.id
  end
end
