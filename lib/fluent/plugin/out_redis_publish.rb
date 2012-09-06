module Fluent
  class RedisPublishOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('redis_publish', self)

    config_param :host,   :string,  :default => '127.0.0.1'
    config_param :path,   :string,  :default => nil
    config_param :port,   :integer, :default => 6379
    config_param :db,     :integer, :default => 0
    config_param :format, :string,  :default => 'json'

    attr_reader :redis

    def initialize
      super
      require 'redis'
      require 'json'
      require 'msgpack'
    end

    def configure(conf)
      super
    end

    def start
      super

      if @path
        @redis = Redis.new(:path => @path, :db => @db)
      else
        @redis = Redis.new(:host => @host, :port => @port, :db => @db);
      end
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      @redis.pipelined do
        chunk.msgpack_each do |(tag, time, record)|
          record["time"] = time

          if @format == "json"
            @redis.publish(tag, record.to_json)
          elsif @format == "msgpack"
            @redis.publish(tag, record.to_msgpack)
          end
        end
      end
    end
  end
end
