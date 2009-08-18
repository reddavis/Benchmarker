require 'helper'

class TestKernel < Test::Unit::TestCase
  
  should "a should contain hello" do
    a = capture_stdout do
      puts "hello"
    end
    assert_match(/hello/, a.string)
  end
  
end
