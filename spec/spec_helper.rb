ENV['DARKSTAR_ENV'] = 'test'
$LOAD_PATH.unshift('./', '../lib').uniq!

require 'mock_redis'

class MockRedis
  def publish(channel, message); end
  def psubscribe(channel); end
end
