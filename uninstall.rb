
puts "\n------------------------------------------------------------------------"
puts "   Uninstalling Typus"
puts "------------------------------------------------------------------------\n\n"

%w( stylesheets images ).each do |f|
  puts " => Removing #{f.capitalize}"
  system "rm #{File.dirname(__FILE__)}/../../../public/#{f}/typus*"
end

puts "Successfully uninstalled Typus ..."