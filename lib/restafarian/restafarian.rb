require 'pp'
module Rack

  # We use this to memoize rack.input reading so we do not
  # lose this in the actual app after reading the stream in
  # our middleware
  # SEEMS TO BE UNCALLED FOR SINCE WE CAN REWIND THE REAL THING
  #class InputWrapper

  #  def initialize(input)
  #    @input = input
  #    @input_data = nil
  #  end

  #  ## * +gets+ must be called without arguments and return a string,
  #  ##   or +nil+ on EOF.
  #  def gets(*args)
  #    return @input_data if @input_data 
  #    @input_data = @input.gets
  #    @input_data 
  #  end


  #  ## * +read+ must be called without or with one integer argument
  #  ##   and return a string, or +nil+ on EOF.
  #  def read(*args)
  #    return @input_data if @input_data 
  #    @input_data  = @input.read(*args)
  #    @input_data 
  #  end

  #  ## * +each+ must be called without arguments and only yield Strings.
  #  def each(*args)
  #    (STDERR.puts( " :DEBUG #{__FILE__}:#{__LINE__} each" ); STDERR.flush ) if ENV['JAMES_SCA_JDEV_MACHINE'] # JGBDEBUG'']"}}"))
  #    @input.each { |line|
  #      yield line
  #    }
  #  end


  #  def rewind *args
  #    # ???
  #  end



  module Neurogami

    class Restafarian

      RESTA_METHODS = %w(index create delete update )
      
      F = ::File

      def to_rest_parts(path)
        # We have some scenarios:
        #  '/'
        #  ''
        #  '/something'
        #  '/something/'
        #  '/foo/bar'
        #
        #  We can strip any wrapping '/' chars so that
        #  we get
        #  ''
        #  'foo'
        #  'foo/bar'
        #
        path.sub!( /^\//, '')
        path.sub!( /\/$/, '')
        path.strip!

        return {:base => '', :args => [] }   if path.empty?

        parts = path.split('/')
        base = parts.shift
        { :base => base, :args => parts }
      end

      def initialize app, path='./'
        @app = app
        @root =  F.expand_path(path)
      end


      def env_input_to_hash env
        input_data = env['rack.input'].read
        return {} if input_data.to_s.strip.empty?
        input_data = CGI.unescape(input_data.to_s.strip)
        return {} unless input_data =~ /=/
        pairs = input_data.split('&')
        h = {}
        pairs.each { |pair| k,v = pair.split('='); h[k] = v }
        h
      end

      def call env 
        path = env["PATH_INFO"]
        request_hash = env_input_to_hash(env) 
        env['rack.input'].rewind
        warn "request_hash  = #{request_hash.pretty_inspect }" 


        # Allow for clients to pass psuedo request type via, say, a form field
        # and update the values passed to the end app

        # Ramaze seems to depend on the request methof being POST or GET; having
        # PUT seems to prevent code from getting the posted values.
        original_request_method  = env['REQUEST_METHOD'].to_s 
        STDERR.puts( ":DEBUG #{__FILE__}:#{__LINE__}    request_hash = #{request_hash.inspect} " ) if ENV['JAMES_SCA_JDEV_MACHINE'] # JGBDEBUG 
        env['REQUEST_METHOD'] = request_hash['X-REQUEST_METHOD'] if request_hash['X-REQUEST_METHOD']
        path_segements = to_rest_parts(path)

        STDERR.puts( "+++++ DEBUG #{__FILE__}:#{__LINE__}  env['REQUEST_METHOD'].upcase = #{env['REQUEST_METHOD'].upcase}" ) if ENV['JAMES_SCA_JDEV_MACHINE'] # JGBDEBUG 

        # Do not allow direct calls to REST mappings
        return [403, {'Content-Type' => 'text/plain'}, '' ]  if  RESTA_METHODS.include?(path_segements[:base])
        return [403, {'Content-Type' => 'text/plain'}, '' ]  if path_segements[:args] && RESTA_METHODS.include?(path_segements[:args].first)

        action = case env['REQUEST_METHOD'].upcase
                 when 'GET'
               '' 
                 when 'PUT' 
               'update'
                 when 'DELETE'
               'delete'
                 when 'POST'
                   #warn (env.methods - Object.methods).sort.join("\n")
                   #rack_response = Rack::Response.new
                   #rack_request = Rack::Request.new(env)
                   #warn rack_request.class
                   #warn (rack_request.methods - Object.methods).sort.join("\n")
                   #warn "BODY: " + rack_request.body.read

               'create'
                 else
               'index' # Maybe not?
                 end

        segments = [path_segements[:base], action, path_segements[:args] ].flatten
        segments.delete_if{|a| a.strip.empty? } 

        new_path = '/' + segments.flatten.join('/')
        env['PATH_INFO']     = new_path 
        env["REQUEST_PATH"]  = new_path 
        env["REQUEST_URI"]   = new_path + ( env['QUERY_STRING'].to_s.strip.empty? ? '' : '?' + env['QUERY_STRING'].to_s.strip )
        env['REQUEST_METHOD']  = original_request_method 
        warn "Middleware Restafarian ..."
       
        STDERR.puts( ":DEBUG #{__FILE__}:#{__LINE__}  New env = #{env.pretty_inspect}" ) if ENV['JAMES_SCA_JDEV_MACHINE'] # JGBDEBUG
        
        
        return @app.call(env)
      end
    end
  end
end
