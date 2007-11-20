def generate_password(length)
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newpass = ""
  1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
  return newpass
end

TYPUS = Hash.new
TYPUS['app_name'] = 'Typus Admin Interface'
TYPUS['app_description'] = 'Web Development for the Masses'
TYPUS['per_page'] = 20
TYPUS['prefix'] = 'admin'
TYPUS['admins'] = [["admin", "typus"]]