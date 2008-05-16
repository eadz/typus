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
      self.columns.map { |u| [u.name, u.type.to_s] }
    end

    # Form and list fields
    #
    # Someday we could use something like:
    #   typus_list_fields :name, :created_at, :updated_at, :status
    #   typus_form_fields :name, :body, :excerpt, :created_at
    #
    def self.typus_fields_for(filter = 'list')

      available_fields = self.model_fields

      available_fields.each do |f|

        ##
        # Some custom field_type depending on the attribute name
        case f.first
          when /_id/:             f[1] = 'collection'
          when /file_name/:       f[1] = 'file'
          when /password/:        f[1] = 'password'
          when 'parent_id':       f[1] = 'tree'
          when 'position':        f[1] = 'position'
        end

      end

      begin
        Typus::Configuration.config["#{self.to_s.titleize}"]["fields"].has_key? filter
        fields = Typus::Configuration.config["#{self.to_s.titleize}"]["fields"][filter]
        custom_available_fields = []
        #fields.each do |f|
        #  custom_available_fields << [f, ]
        #end
        available_fields.each do |af|
          custom_available_fields << af if fields.include? af.first
        end
        return custom_available_fields
      rescue
        return available_fields
      end

    end

    ##
    # Typus sidebar filters.
    #
    # Someday we could use something like:
    #   typus_filters :created_at, :status

    def self.typus_filters
      available_fields = self.model_fields
      fields = Typus::Configuration.config["#{self.to_s.titleize}"]["filters"].split(", ")
      custom_available_fields = []
      available_fields.each { |af| custom_available_fields << af if fields.include? af.first }
      custom_available_fields
    rescue
      []
    end

    ##
    #  Extended actions for this model on Typus.
    #
    # Someday we could use something like:
    #     typus_list_actions :action_one
    #     typus_form_actions :action_two, :action_three

    def self.typus_actions_for(filter = "list")
      Typus::Configuration.config["#{self.to_s.titleize}"]["actions"][filter].split(", ")
    rescue
      []
    end

    ##
    # Used for +search+
    #
    # Someday we could use something like:
    #     typus_search :title, :details
    #
    # Default order is ASC, except for datetime items that is DESC.

    def self.typus_defaults_for(filter)
      Typus::Configuration.config["#{self.to_s.titleize}"][filter].split(", ")
    rescue
      []
    end

    ##
    # Used for +relationships+
    def self.typus_relationships_for(filter)
      begin
        Typus::Configuration.config["#{self.to_s.titleize}"]["relationships"][filter].split(", ")
      rescue
        associations = []
        self.reflections.each do |name, value|
          associations << name.to_s if value.macro.to_s == filter
        end
        associations
      end
    end

    ##
    # Used for +order_by+
    #
    # Someday we could use something like:
    #     typus_order_by :title, :created_at
    #
    def self.typus_order_by
      fields = Typus::Configuration.config["#{self.to_s.titleize}"]["order_by"].split(", ")
      order = []
      fields.each do |field|
        if field.include?("-")
          order << "#{field.delete("-")} DESC"
        else
          order << "#{field} ASC"
        end
      end
      return order.join(", ")
    rescue
      "id ASC"
    end

    ##
    # This is used by acts_as_tree

    def self.top
      find :all, :conditions => [ "parent_id IS ?", nil ]
    end

    ##
    # This is used by acts_as_tree

    def has_children?
      children.size > 0
    end

    def typus_name
      name
    rescue
      "#{self.class}##{id}"
    end

  end

end