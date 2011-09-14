
require 'test/unit'
require 'solaris'

# Unit tests for top level require.
class TestSolaris < Test::Unit::TestCase #:nodoc:

  def test_solaris
    assert_nothing_raised { Solaris }
  end

  def test_solaris_prototype
    assert_nothing_raised { Solaris::Prototype }
  end

end

