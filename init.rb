begin

  ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), 'app', 'views'))

  %w( controllers models helpers ).each do |m|
    Dependencies.load_paths << File.join(File.dirname(__FILE__), 'app', m)
  end

  %w( sha1 ).each { |lib| require lib }

  require 'data_mapper' unless defined?(ActiveRecord)
  require 'paginator'
  require 'typus'

  TYPUS_ROLES = %w( admin editor writer moderator visitor )

  Typus.enable

  Typus::Configuration.options[:version] = '0.9.6 0aca3f992e5f6ef84227ac0408f0597f202a47c4'

rescue LoadError
  puts "=> [TYPUS] Install required plugins and gems with `rake typus:dependencies`"
end