require 'ansible'
require 'json'
require 'digest/md5'
require 'eventmachine'
require 'twitter/json_stream'

class Harvester
  attr_reader :ansible, :credentials

  def initialize(options = {})
    @options = set_default_twitter_options(options)
    @ansible = options[:ansible] || Ansible.new
    @credentials = get_credentials
  end

  def get_credentials
    msg = {:method => 'send_credentials'}
    @ansible.send_home_and_wait(msg, 'credentials')
  end

  def create_stream(options)
    Twitter::JSONStream.connect(
      :method  => 'POST',
      :path    => options[:path],
      :auth    => "#{options[:login]}:#{options[:password]}"
    )
  end

  def call
    EventMachine::run {
      stream = create_stream(@options)

      stream.each_item do |item|
        tweet = JSON.parse(item)
        @ansible.set(tweet[:id], tweet)
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

  def set_default_twitter_options(options)
    options[:method] ||= 'GET'
    options[:path] ||= '/1/statuses/sample.json'
    options
  end
end
