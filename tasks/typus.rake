require File.dirname(__FILE__) + '/../../../../config/environment'

namespace :typus do
  
  desc "Initialize plugin"
  task :init  do
    system "script/generate model user first_name:string last_name:string email:string hashed_password:string status:boolean is_admin:boolean created_at:datetime"
    Rake::Task["db:migrate"].invoke
    system "rm app/models/user.rb"
    User.create(:first_name => 'First Name', :last_name => 'Last Name', :is_admin => true, :status => true, :email => 'admin@foo.com', :password => "typuscms", :password_confirmation => "typuscms")
    # Rake::Task["typus:setup_theme"].invoke
    Rake::Task["typus:generate"].invoke
  end

  desc "Install CSS and images"
  task :setup_theme do
    system "mkdir #{RAILS_ROOT}/public/stylesheets/typus"
    system "mkdir #{RAILS_ROOT}/public/images/typus"
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/stylesheets/* #{RAILS_ROOT}/public/stylesheets/typus"
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/images/* #{RAILS_ROOT}/public/images/typus"
  end

  # FIXME
  desc "Generate typus.yml & setup.yml"
  task :generate do
    begin
      MODEL_DIR = File.join(RAILS_ROOT, "app/models")
      Dir.chdir(MODEL_DIR)
      models = Dir["*.rb"]
      if !File.exists? ("#{RAILS_ROOT}/config/typus.yml")
        typus = File.open("#{RAILS_ROOT}/config/typus.yml", "w+")
        typus.puts "Typus:"
        typus.puts "  app_name: Morning Labs"
        typus.puts "  app_description: Web Development for the Masses"
        typus.puts "  site_name: This is the site name"
        typus.puts "  site_description: This is the site description"
        typus.puts "  version: Typus 2.0a"
        typus.puts "  per_page: 15"
        typus.puts "  project_url: http://intraducibles.net/projects/typus"
        typus.puts ""
        typus.puts "Models:"
        typus.puts "  User:"
        typus.puts "    list: full_name email"
        typus.puts "    form: first_name::string last_name::string email::string password::password password_confirmation::password is_admin::boolean status::boolean"
        typus.puts "    module: system"
        typus.puts "    default: true"
        typus.puts "    order: email::asc"
        typus.puts "    filters: status"
        typus.close
        models.each do |model|
          class_name = eval model.sub(/\.rb$/,'').camelize
          class_attributes = class_name.new.attributes.keys
          typus = File.open("#{RAILS_ROOT}/config/typus.yml", "a+")
          typus.puts "  #{class_name}:"
          list = class_attributes
          list.delete("content")
          list.delete("body")
          typus.puts "    list: #{list.join(", ")}"
          typus.puts "    form:"
          typus.puts "    module:"
          typus.puts "    default:"
          typus.puts "    order:"
          typus.puts "    filters:"
          typus.close
          puts "#{class_name} => #{class_attributes.join(', ')}"
        end
      else
        puts "=> file typus.yml already exists."
      end
    rescue Exception => e
      puts "#{e.message}"
    end
  end

end
