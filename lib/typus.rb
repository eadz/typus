def generate_password(length)
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newpass = ""
  1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
  return newpass
end

if File.exists? "#{RAILS_ROOT}/config/setup.yml"
  TYPUS = YAML.load_file("#{RAILS_ROOT}/config/setup.yml")
end