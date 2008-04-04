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
    end

    def enable_orm
      if defined?(DataMapper)
        require 'typus/data_mapper'
      else
        require 'typus/active_record'
      end
    end

    def enable_routes
      require 'typus/routes'
    end

    def enable_string
      require 'typus/string'
    end

    def enable_authentication
      require 'typus/authentication'
    end

    def enable_patches
      require 'typus/patches'
    end

  end

end