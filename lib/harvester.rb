require 'json'
require 'ansible'
require 'eventmachine'
require 'config/initializers/redis'
require 'twitter/json_stream'

class Harvester
  attr_reader :redis

  def initialize(redis = Ansible.new)
    @redis = redis
  end

  def create_stream(options)
    Twitter::JSONStream.connect(
      :method  => 'POST',
      :path    => options[:path],
      :auth    => "#{options[:login]}:#{options[:password]}"
    )
  end

  def run
    EventMachine::run {
      stream = create_stream({
        :path => 'path',
        :login => 'login',
        :password => 'password'
      })

      stream.each_item do |item|
        tweet = JSON.parse(item)
        @redis.set(tweet[:id], tweet)
        # Do someting with unparsed JSON item.
      end

      stream.on_error do |message|
        # No need to worry here. It might be an issue with Twitter.
        # Log message for future reference. JSONStream will try to reconnect after a timeout.
      end

      stream.on_max_reconnects do |timeout, retries|
        # Something is wrong on your side. Send yourself an email.
      end

      stream.on_no_data do
        # Twitter has stopped sending any data on the currently active
        # connection, reconnecting is probably in order
      end
    }
  end
end
