puts "=> [Typus] Uninstalling plugin"

%w( stylesheets images ).each do |f|
  puts "=>   Removing #{f.capitalize}"
  system "rm #{File.dirname(__FILE__)}/../../../public/#{f}/typus*"
end
