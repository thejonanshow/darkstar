require 'redis'
require './config/secret/redis_password'

unless ENV['RAILS_ENV'] == 'test'
  REDIS = Redis.new(:host => '50.116.34.44', :port => 6379)
  REDIS.auth(REDIS_PASSWORD)
end
