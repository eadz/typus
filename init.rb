controller_path = "#{File.dirname(__FILE__)}/app/controllers"
model_path = "#{File.dirname(__FILE__)}/app/models"
helper_path = "#{File.dirname(__FILE__)}/app/helpers"

$LOAD_PATH << controller_path
$LOAD_PATH << model_path
$LOAD_PATH << helper_path

Dependencies.load_paths += [ controller_path, model_path, helper_path ]
config.controller_paths << controller_path

# Unicode Support

$KCODE = 'u'

# Libraries required

Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |lib| require lib }
Dir["#{RAILS_ROOT}/lib/*.rb"].each { |lib| require lib }
%w( jcode sha1 aws/s3 gettext/rails ).each { |lib| require lib }

# Email Settings

ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default_charset = "utf-8"

# Add methods to AR:Base

class ActiveRecord::Base

  def self.list_fields
    @config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    @config = @config["#{self}"]["list"].split(" ")
    @config = %w( name ) if @config.size == 0
    return @config
  end

  def self.form_fields
    @config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    @config = @config["#{self}"]["form"].split(" ")
    @fields = Array.new
    @config.each do |i|
      @fields << i.split(":")
    end
    @fields << [["name", "string"]] if @fields.size == 0
    return @fields
  end

  def self.default_order
    @config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    @order = Array.new
    if @config["#{self}"]["order"]
      @config = @config["#{self}"]["order"].split(" ")
      @config.each do |i|
        @order << i.split(":")
      end
    else
      @order << ["id", "asc"] # if @order.size == 0
    end
    return @order
  end

end