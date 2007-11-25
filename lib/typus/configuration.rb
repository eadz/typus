module Typus

  module Configuration

    @@options = { 
        :app_name => 'Typus Admin Interface',
        :app_description => 'Web Development for the Masses',
        :per_page => 20,
        :prefix => 'admin',
        :username => 'admin',
        :password => 'typus',
        }

    mattr_reader :options

  end

end
