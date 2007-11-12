require File.dirname(__FILE__) + '/../../../../config/environment'

namespace :typus do
  
  desc "Generate typus.yml & Admin Interface Assets"
  task :setup do
    puts "Creating symlinks ..."
    %w( images stylesheets ).each do |symlink|
      puts "=> Added symlink for #{symlink}"
      system "ln -s #{RAILS_ROOT}/vendor/plugins/typus/public/#{symlink} #{RAILS_ROOT}/public/#{symlink}/typus"
    end
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
        typus.puts "#   list: title"
        typus.puts "#   form: title::string body::text::10 status::boolean created_at::datetime"
        typus.puts "#   module: content"
        typus.puts "#   order: created_at"
        typus.puts "#   filters: status"
        typus.puts "#   search: title body"
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
          typus.puts "  list: #{list.join(" ")}"
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