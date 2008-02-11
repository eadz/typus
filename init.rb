begin
  ActionController::Base.view_paths << File.join(File.dirname(__FILE__), 'app', 'views')

  %w( controllers models helpers ).each do |m|
    Dependencies.load_paths << File.join(File.dirname(__FILE__), 'app', m)
  end

  %w( sha1 ).each { |lib| require lib }

  require "#{RAILS_ROOT}/vendor/plugins/will_paginate/lib/will_paginate"
  require 'typus'

  TYPUS_ROLES = %w( admin editor writer moderator visitor )

  Typus.enable

  Typus::Configuration.options[:version] = '111'

rescue LoadError
  puts "To install required plugins run => rake typus:dependencies"
end