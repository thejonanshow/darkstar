require 'config/initializers/redis.rb'
require 'digest/md5'
require 'json'
require 'lib/com'

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

  def send_home(message)
    message[:to] = @redis.get('mothership_id')
    message[:from] = @id
    publish_message('mothership', message.to_json)
  end

  def send_home_and_wait(message, key)
    send_home(message)
    wait_for_message_with(key)
  end

  def send_message(message, to_id = nil)
    message[:to] = to_id if to_id
    message[:from] = @id
    publish_message('darkstar', message.to_json)
  end

  def send_and_wait(message, key)
    send_message(message)
    wait_for_message_with(key)
  end

  def publish_message(channel, message)
    @redis.publish channel, message
  end

  def generate_id
    id = Digest::MD5.hexdigest("#{Time.now.to_f}#{rand(777)}")
    puts id
    id
  end

  def wait_for_message_with(key)
    Com.new(self).wait_for_message_with(key)
  end

  def new_message(msg)
    puts msg
  end
end
