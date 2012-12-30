require "lit/engine"
require 'lit/loader'

module Lit
  mattr_accessor :authentication_function
  mattr_accessor :key_value_engine
  class << self
    attr_accessor :loader
  end
  def self.init
    if self.loader.nil?
      self.loader ||= Loader.new
      self.loader.cache.load_all_translations
    end
    self.loader
  end

  def self.get_key_value_engine
    case Lit.key_value_engine
        when 'redis'
          require 'lit/adapters/redis_storage'
          RedisStorage.new
        else
          require 'lit/adapters/hash_storage'
          HashStorage.new
    end
  end
end

if defined? Rails
  require 'lit/rails'
end