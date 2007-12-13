require 'fileutils'

# Copy the stylesheets and images.
css = File.dirname(__FILE__) + '/../../../public/stylesheets/typus.css'
FileUtils.cp File.dirname(__FILE__) + '/app/public/stylesheets/typus.css', css unless File.exist?(css)
# images_folder = File.dirname(__FILE__) + '/../../../public/images/'
# system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/#{folder}/* #{RAILS_ROOT}/public/#{folder}/"

# Check `will_paginate` plugin is installed, otherwise we install it.
# will_paginate = File.dirname(__FILE__) + '/../../../public/stylesheets/typus.css'

# File("")

# And finally print a message with the options
# puts "rake typus:config (Installs the `typus.yml` configuration file.)"