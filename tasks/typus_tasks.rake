require File.dirname(__FILE__) + '/../../../../config/environment'

namespace :typus do

  desc "Install plugin dependencies"
  task :dependencies do
    system "script/plugin install svn://errtheblog.com/svn/plugins/will_paginate"
  end

  desc "Update Typus"
  task :update do
    system "script/plugin install http://dev.intraducibles.net/svn/plugins/typus --force"
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
    begin
      MODEL_DIR = File.join(RAILS_ROOT, "app/models")
      Dir.chdir(MODEL_DIR)
      models = Dir["*.rb"]
      if !File.exists? ("#{RAILS_ROOT}/config/typus.yml")
        typus = File.open("#{RAILS_ROOT}/config/typus.yml", "w+")
        typus.puts "# ------------------------------------------------"
        typus.puts "# Typus Configuration File"
        typus.puts "# ------------------------------------------------"
        typus.puts "#"
        typus.puts "# Post:"
        typus.puts "#   list: title::string created_at::datetime"
        typus.puts "#   form: title::string body::text::10 status::boolean created_at::datetime"
        typus.puts "#   order: created_at::asc"
        typus.puts "#   filters: status::boolean created_at::datetime"
        typus.puts "#   search: title body"
        typus.puts "#   module: content"
        typus.puts "#   copy: Some text to describe the model"
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
          typus.puts "  list: #{list.join("::string ")}"
          typus.puts "  form:"
          typus.puts "  module:"
          typus.puts "  order:"
          typus.puts "  filters:"
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