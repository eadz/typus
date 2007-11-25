module Typus

  module Configuration

    class << self

      def app_name
        "Typus Admin Interface"
      end

      def app_description
        "Web Development for the Masses"
      end

      def per_page
        20
      end

      def prefix
        'admin'
      end

      def username
        'admin'
      end

      def password
        'typus'
      end

    end

  end

end
