
require 'test/unit'

# Unit tests for Solaris::Prototype.
class TestPrototype < Test::Unit::TestCase #:nodoc:

  # These don't work on Cygwin. They might work on proper unices.
  #def test_from_path_file
  #  assert( Solaris::Prototype.from_path( __FILE__ ).valid? )
  #end
  #
  #def test_from_path_root
  #  assert( Solaris::Prototype.from_path( '/' ).valid? )
  #end

  def test_character_device
    line = 'c none /dev/null 13 2 0666 root sys'
    proto = Solaris::Prototype.from_line( line )
    assert_equal( :c, proto.ftype )
    assert_equal( 'none', proto.install_class )
    assert_equal( '/dev/null', proto.pathname )
    assert_equal( 13, proto.major )
    assert_equal( 2, proto.minor )
    assert_equal( 438, proto.mode )
    assert_equal( 'root', proto.owner )
    assert_equal( 'sys', proto.group )
    assert( proto.valid? )
    assert_equal( line, proto.to_s )
  end

  def test_symbolic_link
    line = 's none /etc/hosts=./inet/hosts'
    proto = Solaris::Prototype.from_line( line )
    assert_equal( :s, proto.ftype )
    assert_equal( 'none', proto.install_class )
    assert_equal( '/etc/hosts=./inet/hosts', proto.pathname )
    assert_equal( nil, proto.major )
    assert_equal( nil, proto.minor )
    assert_equal( nil, proto.mode )
    assert_equal( nil, proto.owner )
    assert_equal( nil, proto.group )
    assert( proto.valid? )
    assert_equal( line, proto.to_s )
  end

  def test_directory
    line = 'd none /export/home/martin 0755 mcarpenter staff'
    proto = Solaris::Prototype.from_line( line )
    assert_equal( :d, proto.ftype )
    assert_equal( 'none', proto.install_class )
    assert_equal( '/export/home/martin', proto.pathname )
    assert_equal( nil, proto.major )
    assert_equal( nil, proto.minor )
    assert_equal( 493, proto.mode )
    assert_equal( 'mcarpenter', proto.owner )
    assert_equal( 'staff', proto.group )
    assert( proto.valid? )
    assert_equal( line, proto.to_s )
  end

  def test_file
    line = 'f none /export/home/martin/.profile 0755 mcarpenter staff'
    proto = Solaris::Prototype.from_line( line )
    assert_equal( :f, proto.ftype )
    assert_equal( 'none', proto.install_class )
    assert_equal( '/export/home/martin/.profile', proto.pathname )
    assert_equal( nil, proto.major )
    assert_equal( nil, proto.minor )
    assert_equal( 493, proto.mode )
    assert_equal( 'mcarpenter', proto.owner )
    assert_equal( 'staff', proto.group )
    assert( proto.valid? )
    assert_equal( line, proto.to_s )
  end

  def test_part
    line = 'f none /export/home/martin/.profile 0755 mcarpenter staff'
    proto = Solaris::Prototype.from_line( line )
    proto.part = 'part'
    assert_equal( "part #{line}", proto.to_s )
  end

  def test_unknown_ftype
    line = 'X none /export/home/martin/.profile 0755 mcarpenter staff'
    assert_raise ArgumentError do
      Solaris::Prototype.from_line( line )
    end
  end

  def test_unparseable_line
    line = 'f nonsense'
    assert_raise ArgumentError do
      Solaris::Prototype.from_line( line )
    end
  end

  def test_valid
    line = 'f none /export/home/martin/.profile 0755 mcarpenter staff'
    proto = Solaris::Prototype.from_line( line )
    assert( proto.valid? )
    proto.ftype = :invalid
    assert( ! proto.valid? )
    proto.ftype = :d
    assert( proto.valid? )
  end

end

