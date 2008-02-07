puts "\nInstalling Typus"
puts "================="

%w( stylesheets images ).each do |f|
  puts "#{f.capitalize} successfully copied."
  system "cp #{File.dirname(__FILE__)}/public/#{f}/* #{File.dirname(__FILE__)}/../../../public/#{f}/"
end

puts "\nAvailable Tasks"
puts "================"
system "rake -T typus --silent"
puts "\n"