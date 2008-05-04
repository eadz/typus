task :typus do
  system "rake -T typus --silent"
end

namespace :typus do

  desc "Create first TypusUser"
  task :create_user do

    require "#{RAILS_ROOT}/config/environment"
    include Authentication

    # Create the new user with the params.
    email = ENV['email']
    password = ENV['password'] || generate_password

    typus_user = TypusUser.new(:email => email, 
                               :password => password, 
                               :password_confirmation => password, 
                               :first_name => 'Typus',
                               :last_name => 'Admin', 
                               :admin => true,
                               :status => true)
    if typus_user.save
      puts "=> [Typus] Typus User successfully created."
      puts "   Email: #{typus_user.email}"
      puts "   Password: #{password}"
    else
      puts "=> [Typus] Could not create Typus User."
    end
  end

  desc "Add controller to have new actions available"
  task :extra_actions do
    if !File.exists? ("#{RAILS_ROOT}/app/controllers/typus_extras_controller.rb")
      system "script/generate controller typus_extras -q"
      puts "=> [Typus] Added controller `typus_extras`."
    else
      puts "=> [Typus] Controller `typus_extras` already exists."
    end
  end

  desc "Install plugin dependencies"
  task :dependencies do
    # Plugins
    puts "Installing required Plugins ..."
    plugins = [ "http://svn.techno-weenie.net/projects/plugins/attachment_fu/",
                "http://dev.rubyonrails.org/svn/rails/plugins/acts_as_list/",
                "http://dev.rubyonrails.org/svn/rails/plugins/acts_as_tree/"]
    plugins.each do |plugin_url|
      plugin = plugin_url.split("/")[-1]
      puts "=> [Typus] Installing `#{plugin}` plugin."
      system "rm -rf vendor/plugins/#{plugin}"
      system "script/plugin install #{plugin_url} -q"
    end
    # Gems
    puts "Installing required Gems ..."
    gems = [ "paginator" ]
    gems.each do |gem|
      puts "=> [Typus] Installing `#{gem}` gem."
      system "sudo gem install #{gem} --no-rdoc --no-ri"
    end
  end

  desc "Update Typus Plugin"
  task :update do
    system "script/plugin install http://dev.intraducibles.net/svn/rails/plugins/typus --force"
    puts "=> [Typus] Updating Typus Plugin."
  end

  desc "Copy Typus images and stylesheets"
  task :assets do
    %w( images stylesheets ).each do |folder|
      puts "=> [Typus] Added `#{folder}` assets."
      system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/#{folder}/* #{RAILS_ROOT}/public/#{folder}/"
    end
  end

  desc "Generate `config/typus.yml`"
  task :configure do
    begin
      MODEL_DIR = File.join(RAILS_ROOT, "app/models")
      Dir.chdir(MODEL_DIR)
      models = Dir["*.rb"]
      if !File.exists? ("#{RAILS_ROOT}/config/typus.yml")
        require File.dirname(__FILE__) + '/../../../../config/environment'
        typus = File.open("#{RAILS_ROOT}/config/typus.yml", "w+")
        typus.puts "# ------------------------------------------------"
        typus.puts "# Typus Admin Configuration File"
        typus.puts "# ------------------------------------------------"
        typus.puts "#"
        typus.puts "# Post:"
        typus.puts "#   fields:"
        typus.puts "#     list: title, category_id, created_at, status"
        typus.puts "#     form: title, body, status, created_at"
        typus.puts "#     relationship: title, status"
        typus.puts "#   actions:"
        typus.puts "#     list: cleanup"
        typus.puts "#     form: send_as_newsletter"
        typus.puts "#   order_by: created_at"
        typus.puts "#   relationships:"
        typus.puts "#     has_and_belongs_to_many: "
        typus.puts "#     has_many: "
        typus.puts "#   filters: status, created_at, category_id"
        typus.puts "#   search: title body"
        typus.puts "#   module: Content"
        typus.puts "#   description: Some text to describe the model"
        typus.puts "#"
        typus.puts "# ------------------------------------------------"
        typus.puts ""
        typus.puts "Typus User:"
        typus.puts "  fields:"
        typus.puts "    list: first_name, last_name, email, status, admin"
        typus.puts "    form: first_name, last_name, email, password, password_confirmation"
        typus.puts "  actions:"
        typus.puts "    list:"
        typus.puts "    form:"
        typus.puts "  filters: status"
        typus.puts "  search: first_name, last_name, email"
        typus.puts "  module: Typus"
        typus.puts "  description: System Users Administration"
        typus.puts ""
        typus.close
        models.each do |model|
          class_name = eval model.sub(/\.rb$/,'').camelize
          class_attributes = class_name.new.attributes.keys
          typus = File.open("#{RAILS_ROOT}/config/typus.yml", "a+")
          typus.puts ""
          typus.puts "#{class_name}:"
          list = class_attributes
          list.delete("content")
          list.delete("body")
          typus.puts "  fields:"
          typus.puts "    list: #{list.join(", ")}"
          typus.puts "    form: #{list.join(", ")}"
          typus.puts "    relationship: #{list.join(", ")}"
          typus.puts "  actions:"
          typus.puts "    list:"
          typus.puts "    form:"
          typus.puts "  order_by:"
          typus.puts "  relationships:"
          typus.puts "    has_and_belongs_to_many: "
          typus.puts "    has_many: "
          typus.puts "  filters:"
          typus.puts "  search:"
          typus.puts "  module: Untitled"
          typus.puts "  description:"
          typus.close
          puts "=> [Typus] #{class_name} added to `typus.yml`."
        end
      else
        puts "=> [Typus] File `typus.yml` already exists."
      end
    rescue Exception => e
      puts "#{e.message}"
    end
  end

end