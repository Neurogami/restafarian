module Restafarian

  # :stopdoc:
  VERSION = '0.1.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to rquire all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    (STDERR.puts( " \n :DEBUG\n #{__FILE__}:#{__LINE__} self.require_all_libs_relative_to  #{fname}" ); STDERR.flush ) if ENV['JAMES_SCA_JDEV_MACHINE'] # JGBDEBUG
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path( ::File.join(::File.dirname(fname), dir, '**', '*.rb'))
    warn "search_me: #{search_me}" 
       Dir.glob(search_me).sort.each {|rb| 
                                     warn rb
                                     require rb}
  end

end  # module Restafarian

Restafarian.require_all_libs_relative_to(__FILE__)
# EOF
