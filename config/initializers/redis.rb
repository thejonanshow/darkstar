require 'redis'
require 'redis-namespace'
require './config/secret/redis_password'

if ENV['DARKSTAR_ENV'] == 'production'
  redis = Redis.new(:host => '50.116.34.44', :port => 6379)
  redis.auth(REDIS_PASSWORD)
  REDIS = Redis::Namespace.new(:darkstar, redis)
else
  REDIS = true
end
