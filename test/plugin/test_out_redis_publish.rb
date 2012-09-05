require 'helpers'

require 'redis'

$channel = nil
$message = nil

class Redis
  def initialize(options = {})
  end

  def pipelined
    yield self
  end

  def publish(channel, message)
    $channel = channel
    $message = message
  end
end

class RedisPublishOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG1 = %[
  ]
  CONFIG2 = %[
    host 192.168.2.3
    port 9999
    db 3
  ]
  CONFIG3 = %[
    path /tmp/foo.sock
  ]

  def create_driver(conf)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::RedisPublishOutput).configure(conf)
  end

  def test_configure
    # defaults
    d = create_driver(CONFIG1)
    assert_equal "127.0.0.1", d.instance.host
    assert_equal 6379, d.instance.port
    assert_equal nil, d.instance.path
    assert_equal 0, d.instance.db

    # host port db
    d = create_driver(CONFIG2)
    assert_equal "192.168.2.3", d.instance.host
    assert_equal 9999, d.instance.port
    assert_equal nil, d.instance.path
    assert_equal 3, d.instance.db

    # path
    d = create_driver(CONFIG3)
    assert_equal "/tmp/foo.sock", d.instance.path
  end

  def test_write
    d = create_driver(CONFIG1)

    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d.emit({ "foo" => "bar" }, time)
    d.run

    assert_equal "test", $channel
    assert_equal({ "foo" => "bar", "time" => time }, $message)

    d = create_driver(CONFIG1)
    time = Time.parse("2011-02-02 13:14:15 UTC").to_i
    d.emit({ "foo" => "bar", "num" => 123 }, time);
    d.run

    assert_equal({ "foo" => "bar", "num" => 123, "time" => time }, $message)
  end
end
