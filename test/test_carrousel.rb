require 'minitest_helper'

class TestCarrousel < MiniTest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Carrousel::VERSION
  end

  def test_it_does_something_useful
    assert true
  end
end
