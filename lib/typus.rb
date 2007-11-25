module Typus

  class << self

    def enable
      enable_configuration
      enable_activerecord
      enable_routes
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

  end

end