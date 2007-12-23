begin

  ActionController::Base.view_paths << File.join(File.dirname(__FILE__), 'app', 'views')

  %w( controllers models helpers ).each do |m|
    Dependencies.load_paths << File.join(File.dirname(__FILE__), 'app', m)
  end

  %w( sha1 ).each { |lib| require lib }

  require "#{RAILS_ROOT}/vendor/plugins/will_paginate/lib/will_paginate"
  require 'typus'
  Typus.enable

rescue LoadError
  puts "\n************************************************************************"
  puts "**        Install +will_paginate+ plugin to make Typus work           **"
  puts "************************************************************************\n\n"
end
