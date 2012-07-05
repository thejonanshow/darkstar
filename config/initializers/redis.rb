require 'redis'
require 'mock_redis'
require 'redis-namespace'
require './config/secret/redis_password'

if ENV['DARKSTAR_ENV'] == 'production'
  redis = Redis.new(:host => '50.116.34.44', :port => 6379)
  redis.auth(REDIS_PASSWORD)
  REDIS = Redis::Namespace.new(:darkstar, redis)
elsif ENV['DARKSTAR_ENV'] = 'test'
  REDIS = MockRedis.new
else
  redis = Redis.new(:host => 'localhost', :port => 6379)
  REDIS = Redis::Namespace.new(:darkstar, redis)
end
