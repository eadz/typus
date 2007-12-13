require 'fileutils'

css = File.dirname(__FILE__) + '/../../../public/stylesheets/typus.css'
FileUtils.cp File.dirname(__FILE__) + '/app/public/stylesheets/typus.css', css unless File.exist?(css)

puts IO.read(File.join(File.dirname(__FILE__), 'README'))