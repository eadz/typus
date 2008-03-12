module Typus

  class << self

    def enable
      enable_configuration
      enable_orm
      enable_routes
      enable_string
      enable_authentication
    end

    def enable_configuration
      require 'typus/configuration'
      puts "=> [TYPUS] Loaded Configuration File"
    end

    def enable_orm
      if defined?(DataMapper)
        require 'typus/data_mapper'
        puts "=> [TYPUS] Loaded DataMapper"
      else
        require 'typus/active_record'
        puts "=> [TYPUS] Loaded ActiveRecord"
      end
    end

    def enable_routes
      require 'typus/routes'
      puts "=> [TYPUS] Loaded Routes"
    end

    def enable_string
      require 'typus/string'
      puts "=> [TYPUS] Loaded String Extension"
    end

    def enable_authentication
      require 'typus/authentication'
      puts "=> [TYPUS] Loaded Authentication"
    end

  end

end