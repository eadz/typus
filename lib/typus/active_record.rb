module Typus

  class ActiveRecord::Base

    def self.list_fields
      @fields = Typus::Configuration.config["#{self}"]["list"] || Array.new
      if @fields.size > 0
        @fields = @fields.split(" ")
        @fields_with_type = Array.new
        @fields.each do |field|
          columns.each do |column|
            @fields_with_type << [ column.name, column.sql_type ] if field == column.name
          end
        end
      else
        @fields_with_type = [['name', 'string']]
      end
      return @fields_with_type
    end

    def self.form_fields
      @fields = Typus::Configuration.config["#{self}"]["form"] || Array.new
      if @fields.size > 0
        @fields = @fields.split(" ")
        @fields_with_type = Array.new
        @fields.each do |field|
          columns.each do |column|
            @fields_with_type << [ column.name, column.sql_type ] if field == column.name
          end
        end
      else
        @fields_with_type = [['name', 'string']]
      end
      return @fields_with_type
    end

    def self.form_fields_externals
      @fields = Typus::Configuration.config["#{self}"]["form_externals"] || Array.new
      # @fields = Array.new
      if @fields.size > 0
        @fields = @fields.split(" ")
        # @config["#{self}"]["form_externals"].split(" ").each { |i| @fields << i.split("::") }
      end
      # return @fields
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