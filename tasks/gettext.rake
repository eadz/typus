
require 'config/environment'
require 'gettext/utils'

namespace :gettext do

  desc "Create mo-files for L10n"
  task :makemo do
    GetText.create_mofiles(true, "po", "locale")
  end

  desc "Extract translations of the models"
  task :extract_models do
    begin
      MODEL_DIR = File.join(RAILS_ROOT, "app/models")
      Dir.chdir(MODEL_DIR)
      models = Dir["*.rb"]
      models.each do |model|
        class_name = model.sub(/\.rb$/,'').camelize
        klass = class_name.split('::').inject(Object){ |klass, part| klass.const_get(part) }
        fields = klass.instance_variable_get "@gettext_translates"
        if klass < ActiveRecord::Base && !klass.abstract_class? && fields
          puts "Extracting #{class_name}"
          @file = File.join(MODEL_DIR, "contents", "#{klass.to_s.downcase}.txt")
          klass_file = File.open("#{@file}", "w")
          klass_file.puts "=== Model #{klass} ==="
          klass.find(:all).each do |item|
            fields.each { |f| klass_file.puts "_(\"#{item.send(f)}\")\n" if item.send(f) }
          end
          klass_file.close
        else
          puts "Skipping #{class_name}"
        end
      end
    rescue Exception => e
      puts "#{e.message}"
    end
  end

  desc "Update pot/po files to match new version."
  task :updatepo do
    TEXT_DOMAIN = "app"
    VERSION = "app 1.0"
    GetText.update_pofiles(TEXT_DOMAIN, Dir.glob("{app,lib}/**/*.{rb,rhtml,txt}"), VERSION)
  end

end

class ActiveRecord::Base

  def self.gettext_translate(*name)
    @gettext_translates ||= {}
    @gettext_translates = *name
    if @gettext_translates.class == Symbol
      @gettext_translates_old = @gettext_translates
      @gettext_translates = Array.new
      @gettext_translates << @gettext_translates_old
    end
  end

end