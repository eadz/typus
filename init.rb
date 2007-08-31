controller_path = "#{File.dirname(__FILE__)}/app/controllers"
model_path = "#{File.dirname(__FILE__)}/app/models"
helper_path = "#{File.dirname(__FILE__)}/app/helpers"

$LOAD_PATH << controller_path
$LOAD_PATH << model_path
$LOAD_PATH << helper_path

Dependencies.load_paths += [ controller_path, model_path, helper_path ]
config.controller_paths << controller_path

#ActionController::Routing::Routes.draw do |map|
#  prefix = 'admin'
#  map.login "#{prefix}/login", :controller => 'sessions', :action => 'create'
#end

# Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |lib| require lib }

class ActionController::Routing::RouteSet
  alias_method :draw_without_admin, :draw
  def draw_with_admin
    draw_without_admin do |map|
      prefix = 'admin'
      map.login "#{prefix}/login", :controller => 'sessions', :action => 'create'
      map.logout "#{prefix}/logout", :controller => 'sessions', :action => 'destroy'
      map.password_recover "#{prefix}/password_recover", :controller => 'sessions', :action => 'password_recover'
      map.with_options :controller => 'typus' do |i|
        i.admin "#{prefix}", :action => 'index'
        i.connect "#{prefix}/-/:action/:id", :action => 'index', :requirements => { :model => nil }
        i.connect "#{prefix}/asset/*path", :action => 'asset'
        i.connect "#{prefix}/:model/:action", :action => 'index', :requirements => { :action => /[^0-9].*/, :id => nil }
        i.connect "#{prefix}/:model/:id/:action", :action => 'edit', :requirements => { :id => /\d+/ }
      end
      yield map
    end
  end
  alias_method :draw, :draw_with_admin
end


class ActiveRecord::Base

  def self.list_fields
    @config = YAML.load_file("#{RAILS_ROOT}/config/admin.yml")
    @config = @config["#{self}"]["list"].split(" ")
    @config = %w( name ) if @config.size == 0
    return @config
  end

  def self.form_fields
    @config = YAML.load_file("#{RAILS_ROOT}/config/admin.yml")
    @config = @config["#{self}"]["form"].split(" ")
    @fields = Array.new
    @config.each do |i|
      @fields << i.split(":")
    end
    @fields << [["name", "string"]] if @fields.size == 0
    return @fields
  end

end

TYPUS = Hash.new
TYPUS[:version] = "Typus 2.0a"
TYPUS[:project_url] = "http://intraducibles.net/projects/typus"
TYPUS[:licenses] = [["Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License", "license-1"],
                    ["License 2", "license-2"],
                    ["All Rights Reserved", "all-rights-reserved"]]
TYPUS[:text_filters] = [['<None>', "none"],
                        ['Textile', "textile"],
                        ['Markdown', "markdown"],
                        ["Test", "test"]]
TYPUS[:admin] = YAML.load_file("#{RAILS_ROOT}/config/admin.yml")
