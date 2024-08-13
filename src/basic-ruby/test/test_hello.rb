# frozen_string_literal: true

require 'minitest/autorun'

require 'hello'

class TestHello < Minitest::Test
  def setup
    @hello = Hello.new
  end

  def test_hello
    assert_equal 'Hello, World!', @hello.message
  end
end
