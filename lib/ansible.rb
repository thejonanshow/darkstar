require 'config/initializers/redis.rb'

class Ansible
  def initialize(redis = REDIS)
    @redis = redis
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

  def get_credentials(id)
  end

  def send_credential(credential_json)
  end
end
