module Typus

  class << self

    def enable
      enable_configuration
      enable_activerecord
      enable_routes
      enable_string
    end

    def enable_configuration
      require 'typus/configuration'
    end

    def enable_activerecord
      require 'typus/active_record'
    end

    def enable_routes
      require 'typus/routes'
    end

    def enable_string
      require 'typus/string'
    end

  end

end