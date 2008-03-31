module Typus

  class << self

    def enable
      enable_configuration
      enable_orm
      enable_routes
      enable_string
      enable_authentication
      enable_patches if Rails.vendor_rails?
    end

    def enable_configuration
      require 'typus/configuration'
      puts "=> [TYPUS] Loaded Configuration File" unless RAILS_ENV == 'production'
    end

    def enable_orm
      if defined?(DataMapper)
        require 'typus/data_mapper'
        puts "=> [TYPUS] Loaded DataMapper" unless RAILS_ENV == 'production'
      else
        require 'typus/active_record'
        puts "=> [TYPUS] Loaded ActiveRecord" unless RAILS_ENV == 'production'
      end
    end

    def enable_routes
      require 'typus/routes'
      puts "=> [TYPUS] Loaded Routes" unless RAILS_ENV == 'production'
    end

    def enable_string
      require 'typus/string'
      puts "=> [TYPUS] Loaded String Extension" unless RAILS_ENV == 'production'
    end

    def enable_authentication
      require 'typus/authentication'
      puts "=> [TYPUS] Loaded Authentication" unless RAILS_ENV == 'production'
    end

    def enable_patches
      require 'typus/patches'
      puts "=> [TYPUS] Loaded Patches" unless RAILS_ENV == 'production'
    end

  end

end