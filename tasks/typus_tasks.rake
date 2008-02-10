namespace :typus do

  desc "Add controller to have new actions available"
  task :extra_actions do
    if !File.exists? ("#{RAILS_ROOT}/app/controllers/typus_extras_controller.rb")
      typus_extra = File.open("#{RAILS_ROOT}/app/controllers/typus_extras_controller.rb", "w+")
      typus_extra.puts "class TypusExtrasController < TypusController"
      typus_extra.puts "end"
      typus_extra.close
      puts "\nTypus"
      puts "====="
      puts "=> Added controller +typus_extras+"
      puts ""
    else
      puts "\nTypus"
      puts "====="
      puts "=> Controller +typus_extras+ already exists."
      puts ""
    end
  end

  desc "Install plugin dependencies"
  task :dependencies do
    puts "Installing required plugins ..."
    plugins = [ "svn://errtheblog.com/svn/plugins/will_paginate",
                "acts_as_list",
                "http://svn.techno-weenie.net/projects/plugins/attachment_fu/"]
    plugins.each do |plugin|
      puts "=> Installing +#{plugin.split("/")[-1]}+ plugin"
      system "script/plugin install #{plugin} -q"
    end
  end

  desc "Update Typus"
  task :update do
    system "script/plugin install http://dev.intraducibles.net/svn/rails/plugins/typus --force"
  end

  desc "Copy Typus images and stylesheets"
  task :assets do
    puts "Coping admin interface assets ..."
    %w( images stylesheets ).each do |folder|
      puts "=> Added *#{folder}* assets"
      system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/#{folder}/* #{RAILS_ROOT}/public/#{folder}/"
    end
  end

  desc "Generate +config/typus.yml+"
  task :setup do
    require File.dirname(__FILE__) + '/../../../../config/environment'
    begin
      MODEL_DIR = File.join(RAILS_ROOT, "app/models")
      Dir.chdir(MODEL_DIR)
      models = Dir["*.rb"]
      if !File.exists? ("#{RAILS_ROOT}/config/typus.yml")
        typus = File.open("#{RAILS_ROOT}/config/typus.yml", "w+")
        typus.puts "# ------------------------------------------------"
        typus.puts "# Typus Admin Configuration File"
        typus.puts "# ------------------------------------------------"
        typus.puts "#"
        typus.puts "# Post:"
        typus.puts "#   fields:"
        typus.puts "#     list: title, category_id, created_at, status"
        typus.puts "#     form: title, body, status, created_at"
        typus.puts "#   actions:"
        typus.puts "#     list: cleanup"
        typus.puts "#     form: send_as_newsletter"
        typus.puts "#   order_by: created_at"
        typus.puts "#   relationships: categories"
        typus.puts "#   filters: status, created_at, category_id"
        typus.puts "#   search: title body"
        typus.puts "#   module: Content"
        typus.puts "#   description: Some text to describe the model"
        typus.puts "#"
        typus.puts "# ------------------------------------------------"
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
          typus.puts "  actions:"
          typus.puts "    list:"
          typus.puts "    form:"
          typus.puts "  order_by:"
          typus.puts "  relationships:"
          typus.puts "  filters:"
          typus.puts "  search:"
          typus.puts "  module: Untitled"
          typus.puts "  description:"
          typus.close
          puts "#{class_name} => #{class_attributes.join(", ")}"
        end
      else
        puts "=> file typus.yml already exists."
      end
    rescue Exception => e
      puts "#{e.message}"
    end
  end

end