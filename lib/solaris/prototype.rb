
require 'etc'

module Solaris

  # Class to represent Solaris package file prototypes.
  # A prototype line contains information regarding file
  # type, location, ownership, permisions.
  #
  # See Solaris' prototype(4) man-page for information on
  # attributes.
  #
  # This class does not support special lines (those
  # beginning with !), pathname variable substitution or
  # prototype parts.
  class Prototype

    attr_accessor :part
    attr_accessor :ftype
    attr_accessor :install_class
    attr_accessor :pathname
    attr_accessor :major
    attr_accessor :minor
    attr_accessor :mode
    attr_accessor :owner
    attr_accessor :group

    # Install class to use if not specified.
    DEFAULT_INSTALL_CLASS = 'none'

    # Part to use if not specified. Solaris 10 documentation
    # for prototype(4) states that no part given implies
    # "part 1".
    DEFAULT_PART = nil

    # Regular expression for filetype.
    RE_FTYPE = '([bcdefpvxils])'

    # Regular expression for install class.
    RE_INSTALL_CLASS = '(\w{1,12})'

    # Regular expression for path.
    RE_PATH = '(\S+)'

    # Regular expression for major device mode.
    RE_MAJOR = '(\d+)'

    # Regular expression for minor device mode.
    RE_MINOR = '(\d+)'

    # Regular expression for octal file mode.
    RE_MODE = '([0-7]{4})'

    # Regular expression for user name.
    RE_OWNER = '(\S+)'

    # Regular expression for group name.
    RE_GROUP = '(\S+)'

    # Create a Prototype object from a line from a prototype(4) file.
    def self.from_line(line)
      ftype = $1.to_sym if line =~ /^#{RE_FTYPE} /
        re = case ftype
             when :b, :c
               /^#{ftype} #{RE_INSTALL_CLASS} #{RE_PATH} #{RE_MAJOR} #{RE_MINOR} #{RE_MODE} #{RE_OWNER} #{RE_GROUP}$/
             when :d, :e, :f, :p, :v, :x
               /^#{ftype} #{RE_INSTALL_CLASS} #{RE_PATH} #{RE_MODE} #{RE_OWNER} #{RE_GROUP}$/
             when :i
               /^#{ftype} #{RE_PATH}/ # perhaps not really path
             when :l, :s
               /^#{ftype} #{RE_INSTALL_CLASS} #{RE_PATH}/
             else
               raise ArgumentError, 'Unknown filetype'
             end
      if line =~ re
        proto = self.new
        proto.ftype = ftype
        case ftype
        when :b, :c
          proto.install_class = $1
          proto.pathname =$2
          proto.major = $3.to_i
          proto.minor = $4.to_i
          proto.mode = $5.to_i(8)
          proto.owner = $6
          proto.group = $7
        when :d, :e, :f, :p, :v, :x
          proto.install_class = $1
          proto.pathname = $2
          proto.mode = $3.to_i(8)
          proto.owner = $4
          proto.group = $5
        when :i
          proto.pathname = $1
        when :l, :s
          proto.install_class = $1
          proto.pathname = $2
        end
      else
        if line =~ /^!/
          raise ArgumentError, "Prototype commands not supported #{line.inspect}"
        else
          raise ArgumentError, "Could not parse line #{line.inspect}"
        end
      end
      proto
    end

    # Create a Prototype from the file at the +path+ on the local
    # filesystem.
    #
    # If +actual+ is provided then this is the path that is used for the
    # object's pathname property although all other properties are
    # created from the +path+ argument. The process must be able to
    # stat(1) the file at +path+ to determine these properties.
    #
    # If this object is to be fed to pkgmk(1M) to be installed at
    # +real_location+ and the file that will be used to construct the
    # package currently lives at +current_location+ then the second
    # argument should take the form +real_location+=+current_location+.
    # The first argument (+path+) is always the file from which the
    # Prototype's properties only (eg. owner, mode) are created.
    #
    # For example, to take the object attributes from the already
    # installed file in /opt/MYpkg/foo, but to subsequently package the
    # file ./foo in that same location using pkgmk(1M) call:
    #     from_path( '/opt/MYpkg/foo', '/opt/MYpkg/foo=./foo' )
    def self.from_path(path, actual=nil)
      proto = self.new
      proto.part = DEFAULT_PART
      # Use #lstat since we are always interested in the link source,
      # not the target.
      stat = File.lstat( path )
      raise RuntimeError, 'Unknown file type' if stat.ftype == 'unknown'
      # Stat returns "link" for symlink, not "symlink"
      proto.ftype = stat.symlink? ? :s : stat.ftype[0].to_sym
      proto.pathname = actual ? actual : path
      proto.part = nil
      proto.install_class = DEFAULT_INSTALL_CLASS
      if [ :b, :c ].include?( proto.ftype )
        proto.major = stat.dev_major
        proto.minor = stat.dev_minor
      end
      proto.mode = stat.mode & 07777
      proto.owner = Etc.getpwuid( stat.uid ).name
      proto.group = Etc.getgrgid( stat.gid ).name
      proto
    end

    # Convert the object to a prototype(4) line (string).
    def to_s
      ( ( @part ? [ @part ] : [] ) +
       case @ftype
       when :b, :c
         [ @ftype.to_s, @install_class, @pathname, @major, @minor, '%04o' % @mode, @owner, @group ]
       when :d, :e, :f, :p, :v, :x
         [ @ftype.to_s, @install_class, @pathname, '%04o' % @mode, @owner, @group ]
       when :i
         [ @ftype.to_s, @pathname ]
       when :l, :s
         [ @ftype.to_s, @install_class, @pathname ]
       else
         raise RuntimeError, "Unknown ftype #{@ftype.inspect}"
       end ).join(' ')
    end

    # Returns true if the object is a valid prototype specification, false
    # otherwise.
    def valid?
      begin
        self.class.from_line( to_s )
      rescue ArgumentError, RuntimeError
        false
      else
        true
      end

    end

  end # Prototype

end # Solaris

