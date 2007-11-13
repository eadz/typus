# Add new locations of the controllers, models & helpers
ActionController::Base.view_paths << File.join(File.dirname(__FILE__), 'app', 'views')
%w( controllers models helpers ).each { |m| Dependencies.load_paths << File.join(File.dirname(__FILE__), 'app', m) }

# Load gems
%w( sha1 ).each { |lib| require lib }

# Libraries required
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| require lib }