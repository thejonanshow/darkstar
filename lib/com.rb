class Com
  attr_reader :redis

  def initialize(caller)
    @redis = caller.redis
    @caller = caller
  end

  def run
    puts "subscribed to #{REDIS.inspect}"
    @redis.psubscribe('*') do |on|
      on.pmessage do |pattern, channel, msg|
        @caller.new_message(msg) if my_message?(msg)
      end
    end
  end

  def wait_for_message_with(key)
    puts "wait_for_message_with"
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
