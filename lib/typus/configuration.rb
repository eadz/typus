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
        :app_name => 'Typus',
        :app_description => '',
        :per_page => 15,
        :prefix => 'admin',
        :username => 'admin',
        :password => 'typus',
        :version => "2.0a",
        :signature => ""
        }
    mattr_reader :options

    # Read Typus Configuration file
    # 
    # Example:
    #
    #
    @@config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    mattr_reader :config

  end

end
