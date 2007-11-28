module Typus

  module Configuration

    @@options = { 
        :app_name => 'Typus Admin Interface',
        :app_description => 'Web Development for the Masses',
        :per_page => 20,
        :prefix => 'admin',
        :username => 'admin',
        :password => 'typus',
        :version => "Typus 2.0a",
        :signature => "Built by Francesc Esplugas"
        }

    mattr_reader :options

  end

end
