module Typus

  class ActiveRecord::Base

    def self.find_previous(current, condition)
      find :first, 
           :order => "#{condition} DESC", 
           :conditions => ["#{condition} < ?", current]
    end

    def self.find_next(current, condition)
      find :first, 
           :order => "#{condition} ASC", 
           :conditions => ["#{condition} > ?", current]
    end

    def self.fields(filter)
      available_fields = self.inspect.gsub("#{self}", "").gsub("(", "").gsub(")", "").split(", ")
      fields = Typus::Configuration.config["#{self}"]['fields'][filter].split(" ")
      fields_with_type = Array.new
      fields.each do |f|
        available_fields.each do |af|
          af = af.split(": ")
          @field_type = af[1] if af[0] == f
          case f
          when /_id/
            @field_type = 'selector'
          when 'uploaded_data'
            @field_type = 'blob'
          end
        end
        fields_with_type << [ f, @field_type ]
      end
      return fields_with_type
    rescue
      []
    end

    def self.default_order
      @config = Typus::Configuration.config
      @order = Array.new
      if @config["#{self}"]["order_by"]
        @config["#{self}"]["order_by"].split(" ").each { |i| @order << i.split("::") }
      else
        @order << ['id', 'asc']
      end
      return @order
    end

    def self.search_fields
      config = Typus::Configuration.config
      search = Array.new
      if config["#{self}"]["search"]
        config = config["#{self}"]["search"].split(" ")
        config.each { |i| ( search ) << i }
      end
      return search
    end

    def self.filters
      available_fields = self.inspect.gsub("#{self}", "").gsub("(", "").gsub(")", "").split(", ")
      fields = Typus::Configuration.config["#{self}"]['filters'].split(" ")
      fields_with_type = Array.new
      fields.each do |f|
        available_fields.each do |af|
          af = af.split(": ")
          @field_type = af[1] if af[0] == f
        end
        fields_with_type << [ f, @field_type ]
      end
      return fields_with_type
    rescue
      []
    end

    def self.actions(filter)
      config = Typus::Configuration.config
      actions = config["#{self}"]['actions'][filter].split(" ")
      return actions
    end

    def self.related
      config = Typus::Configuration.config
      related = config["#{self}"]['related'].split(" ")
      return related
    rescue
      []
    end

  end

end