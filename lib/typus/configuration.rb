module Typus

  module Configuration

    # Default application options that can be overwritten from
    # an initializer.
    #
    # Example:
    # Typus::Configuration.options[:app_name] = "Your App Name"
    # Typus::Configuration.options[:per_page] = 15
    #
    @@options = {
        :app_name => 'Typus Admin',
        :app_description => '',
        :per_page => 15,
        :prefix => 'admin',
        :username => 'admin',
        :password => 'typus',
        :version => '',
        :signature => ''
        }
    mattr_reader :options

    # Read Typus Configuration file
    # 
    # Example:
    #
    #
    if ENV["RAILS_ENV"] == 'test'
      @@config = YAML.load_file("#{File.dirname(__FILE__)}/../../test/typus.yml")
    else
      @@config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml") if File.exists?("#{RAILS_ROOT}/config/typus.yml")
    end
    mattr_reader :config

  end

end