%w( stylesheets images ).each do |f|
  system "cp #{File.dirname(__FILE__)}/public/#{f}/* #{File.dirname(__FILE__)}/../../../public/#{f}/"
end

puts "[Typus] Available Tasks"
system "rake typus"