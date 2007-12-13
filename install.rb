require 'fileutils'

css = File.dirname(__FILE__) + '/../../../public/stylesheets/typus.css'
FileUtils.cp File.dirname(__FILE__) + '/app/public/stylesheets/typus.css', css unless File.exist?(css)

# Images
# images_folder = File.dirname(__FILE__) + '/../../../public/images/'
# system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/#{folder}/* #{RAILS_ROOT}/public/#{folder}/"

puts IO.read(File.join(File.dirname(__FILE__), 'README'))