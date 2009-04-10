# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'restafarian'

task :default => 'spec:run'

PROJ.name = 'restafarian'
PROJ.authors = 'James Britt'
PROJ.email = 'james@neurogami.com'
PROJ.url = 'neurogami.com/code/restafarian'
PROJ.version = Restafarian::VERSION
# PROJ.rubyforge.name = 'restafarian'

PROJ.spec.opts << '--color'

# EOF
