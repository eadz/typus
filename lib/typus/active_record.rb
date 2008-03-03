module Typus

  class ActiveRecord::Base

    def self.typus_find_previous(current, condition)
      find :first, 
           :order => "#{condition} DESC", 
           :conditions => ["#{condition} < ?", current]
    end

    def self.typus_find_next(current, condition)
      find :first, 
           :order => "#{condition} ASC", 
           :conditions => ["#{condition} > ?", current]
    end

    def self.model_fields
      fields = []
      self.columns.each { |column| fields << [column.name, column.type.to_s] }
      return fields
    end

    # Form and list fields
    #
    # Someday we could use something like:
    #   typus_list_fields :name, :created_at, :updated_at, :status
    #   typus_form_fields :name, :body, :excerpt, :created_at
    #
    def self.typus_fields_for(filter)
      available_fields = self.model_fields
      fields = Typus::Configuration.config["#{self.to_s.titleize}"]["fields"][filter].split(", ")
      fields_with_type = []
      fields.each do |f|
        available_fields.each do |af|
          @field_type = af[1] if af[0] == f
          case f
            when 'parent_id':       @field_type = 'tree'
            when /_id/:             @field_type = 'collection'
            when /password/:        @field_type = 'password'
            when 'uploaded_data':   @field_type = 'blob'
            when 'position':        @field_type = 'position'
            when 'preview':         @field_type = 'preview'
          end
        end
        @field_type = (eval f.upcase) rescue @field_type
        @field_type = 'selector' if @field_type.class == Array
        fields_with_type << [ f, @field_type ]
      end
      return fields_with_type
    rescue
      self.typus_fields_for('list')
    end

    # Typus sidebar filters.
    #
    # Someday we could use something like:
    #   typus_filters :created_at, :status
    #
    def self.typus_filters
      available_fields = self.model_fields
      fields = Typus::Configuration.config["#{self.to_s.titleize}"]["filters"].split(", ")
      fields_with_type = Array.new
      fields.each do |f|
        available_fields.each do |af|
          @field_type = af[1] if af[0] == f
        end
        fields_with_type << [ f, @field_type ]
      end
      return fields_with_type
    rescue
      []
    end

    #  Extended actions for this model on Typus.
    #
    # Someday we could use something like:
    #     typus_list_actions :action_one
    #     typus_form_actions :action_two, :action_three
    #
    def self.typus_actions_for(filter)
      Typus::Configuration.config["#{self.to_s.titleize}"]["actions"][filter].split(", ")
    rescue
      []
    end

    # Used for +order_by+, +related+, +search+ and more ...
    #
    # Someday we could use something like:
    #     typus_search :title, :details
    #     typus_related :tags, :categories
    #     typus_order_by :title, :created_at
    #
    # Default order is ASC, except for datetime items that is DESC.
    def self.typus_defaults_for(filter)
      Typus::Configuration.config["#{self.to_s.titleize}"][filter].split(", ")
    rescue
      []
    end

    # This is used by acts_as_tree
    def self.top
      find :all, :conditions => [ "parent_id IS ?", nil ]
    end

    # This is used by acts_as_tree
    def has_children?
      children.size > 0
    end

  end

end