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

    def self.list_fields
      @config = Typus::Configuration.config["#{self}"]["list"].split(" ")
      @fields = Array.new
      @config.each { |i| (@fields ) << i.split("::") }
      @fields << [["name", "string"]] if @fields.size == 0
      return @fields
    end

    def self.form_fields
      @config = Typus::Configuration.config["#{self}"]["form"].split(" ")
      @fields = Array.new
      @config.each { |i| @fields << i.split("::") }
      @fields << [["name", "string"]] if @fields.size == 0
      return @fields
    end

    def self.form_fields_externals
      @config = Typus::Configuration.config
      @fields = Array.new
      if @config["#{self}"]["form_externals"]
        @config["#{self}"]["form_externals"].split(" ").each { |i| @fields << i.split("::") }
      end
      return @fields
    end

    def self.default_order
      @config = Typus::Configuration.config
      @order = Array.new
      if @config["#{self}"]["order"]
        @config["#{self}"]["order"].split(" ").each { |i| @order << i.split("::") }
      else
        @order << ['id', 'asc']
      end
      return @order
    end

    def self.search_fields
      @config = Typus::Configuration.config
      @search = Array.new
      if @config["#{self}"]["search"]
        @config = @config["#{self}"]["search"].split(" ")
        @config.each { |i| ( @search ) << i }
      end
      return @search
    end

    def self.filters
      @config = Typus::Configuration.config
      @filters = Array.new
      if @config["#{self}"]["filters"]
        @config = @config["#{self}"]["filters"].split(" ")
        @config.each { |i| @filters << i.split("::") }
      end
      return @filters
    end

    def self.actions
      @config = Typus::Configuration.config
      @actions = Array.new
      if @config["#{self}"]["actions"]
        @config = @config["#{self}"]["actions"].split(" ")
        @config.each { |i| ( @actions ) << i.split("::") }
      end
      return @actions
    end

  end

end