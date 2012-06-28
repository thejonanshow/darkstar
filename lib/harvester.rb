require 'json'
require 'ansible'
require 'eventmachine'
require 'config/secret/twitter_credentials'
require 'twitter/json_stream'
require 'digest/md5'

class Harvester
  attr_reader :ansible, :credentials

  def initialize(options = {})
    @options = set_default_twitter_options(options)
    @ansible = options[:ansible] || Ansible.new
    @credentials = @ansible.get_credentials
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
