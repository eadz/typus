module SessionsHelper

  TYPUS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")["Typus"]

  def head
    @block = "<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\" />"
    @block += "<title>#{TYPUS["app_name"]} | #{TYPUS["app_description"]}</title>"
    @block += stylesheet_link_tag "typus/login", :media => "screen"
    return @block
  end

  def header
    @block = "<h1><a href=\"/admin\">#{TYPUS["app_name"]}</a></h1>"
    return @block
  end

end