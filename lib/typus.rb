module Typus

  class << self

    def applications
      apps = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1].has_key? 'application'
          apps << model[1]['application']
        end
      end
      return apps.uniq
    end

    def modules(app_name)
      submodules = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1]['application'] == app_name
          submodules << model[0]
        end
      end
      return submodules
    end

    def submodules(module_name)
      submodules = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1]['module'] == module_name
          submodules << model[0]
        end
      end
      return submodules
    end

    def parent_module(submodule_name)
      # TODO
    end

    def parent_app(module_name)
      # TODO
    end

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