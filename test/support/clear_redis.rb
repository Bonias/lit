require 'redis'
def clear_redis
  if defined?($redis) && !$redis.nil?
    keys = $redis.keys("lit:#{Lit.storage_options[:prefix]}*")
    $redis.del keys unless keys.empty?
  end
end
