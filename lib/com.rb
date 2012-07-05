require 'json'

class Com
  attr_reader :redis, :caller

  def initialize(caller)
    @redis = caller.redis || REDIS
    @caller = caller
  end

  def call
    @redis.psubscribe('*') do |on|
      on.pmessage do |pattern, channel, msg|
        parsed = JSON.parse(msg)
        @caller.new_message(parsed) if my_message?(parsed)
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
