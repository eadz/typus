puts "\n------------------------------------------------------------------------"
puts "   Installing Typus"
puts "------------------------------------------------------------------------\n\n"

%w( stylesheets images ).each do |f|
  puts " => Copying #{f.capitalize}"
  system "cp #{File.dirname(__FILE__)}/public/#{f}/* #{File.dirname(__FILE__)}/../../../public/#{f}/"
end

puts "\n------------------------------------------------------------------------"
puts "   Available Tasks"
puts "------------------------------------------------------------------------\n\n"

puts " - rake typus:dependencies"
puts "   Installs +will_paginate+ plugin"
puts ""
puts " - rake typus:config"
puts "   Generates +config/typus.yml+ config file."
puts ""