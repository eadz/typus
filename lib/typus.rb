def generate_password(length)
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newpass = ""
  1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
  return newpass
end

TYPUS = Hash.new
TYPUS[:app_name] = "Morning Labs"
TYPUS[:app_description] = "Web Development for the Masses"
TYPUS[:site_name] = "This is the site name"
TYPUS[:site_description] = "This is the site description"
TYPUS[:version] = "Typus 2.0a"
TYPUS[:project_url] = "http://intraducibles.net/projects/typus"
TYPUS[:licenses] = [["Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License", "license-1"],
                    ["License 2", "license-2"],
                    ["All Rights Reserved", "all-rights-reserved"]]
TYPUS[:text_filters] = [['<None>', "none"],
                        ['Textile', "textile"],
                        ['Markdown', "markdown"],
                        ["Test", "test"]]