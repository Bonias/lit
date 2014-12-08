require 'redis'
module Lit
  extend self
  def redis
    $redis = Redis.new(url: ENV['REDIS_URL']) unless $redis
    $redis
  end
  class RedisStorage
    def initialize
      Lit.redis
    end

    def [](key)
      key_for_arr = _prefixed_key_for_array(key)
      key_for_nil = _prefixed_key_for_nil(key)

      is_array, is_nil, ret =
        Lit.redis.mget(key_for_arr, key_for_nil, _prefixed_key(key))

      if is_array
        Lit.redis.lrange(_prefixed_key(key), 0, -1)
      elsif is_nil
        nil
      else
        ret
      end
    end

    def []=(k, v)
      delete(k)
      if v.is_a?(Array)
        Lit.redis.set(_prefixed_key_for_array(k), '1')
        v.each do |ve|
          Lit.redis.rpush(_prefixed_key(k), ve.to_s)
        end
      elsif v.nil?
        Lit.redis.set(_prefixed_key_for_nil(k), '1')
        Lit.redis.set(_prefixed_key(k), '')
      else
        Lit.redis.set(_prefixed_key(k), v)
      end
    end

    def delete(k)
      keys = []
      keys << _prefixed_key_for_array(k)
      keys << _prefixed_key_for_nil(k)
      keys << _prefixed_key(k)
      Lit.redis.del(keys)
    end

    def clear
      Lit.redis.del(keys) if keys.length > 0
    end

    def keys
      Lit.redis.keys(_prefixed_key + '*')
    end

    def has_key?(key)
      Lit.redis.exists(_prefixed_key(key))
    end

    def incr(key)
      Lit.redis.incr(_prefixed_key(key))
    end

    def sort
      Lit.redis.keys.sort.map do |k|
        [k, self.[](k)]
      end
    end

    private

    def _prefix
      @_prefix ||= begin
        prefix = 'lit:'
        if Lit.storage_options.is_a?(Hash)
          prefix << "#{Lit.storage_options[:prefix]}:" if Lit.storage_options.key?(:prefix)
        end
        prefix
      end
    end

    def _prefixed_key(key = '')
      _prefix + key.to_s
    end

    def _prefixed_key_for_array(key = '')
      _prefix + 'array_flags:' + key.to_s
    end

    def _prefixed_key_for_nil(key = '')
      _prefix + 'nil_flags:' + key.to_s
    end
  end
end
