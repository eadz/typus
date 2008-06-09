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
      self.columns.map { |u| ["#{u.name}", "#{u.type}"] }
    end

    # Form and list fields
    #
    # Someday we could use something like:
    #   typus_list_fields :name, :created_at, :updated_at, :status
    #   typus_form_fields :name, :body, :excerpt, :created_at
    #
    def self.typus_fields_for(filter)

      available_fields = self.model_fields
      if Typus::Configuration.config["#{self.name}"]["fields"].has_key? filter
        fields = Typus::Configuration.config["#{self.name}"]["fields"][filter]
        fields = (fields.nil?) ? available_fields : fields.split(", ")
      else
        fields = available_fields
      end

      fields_with_type = []
      fields.each do |f|

        ##
        # Get the field_type for each field
        available_fields.each do |af|
          @field_type = af.last if af.first == f
        end

        ##
        # Some custom field_type depending on the attribute name
        # TODO: handle case where foriegn key doesn't end in _id
        # TODO: e.g. you have a has_many :cars, :foreign_key => 'monkey'
        case f
          when 'parent_id':       @field_type = 'tree'
          when /_id/:             @field_type = 'collection'
          when /file_name/:       @field_type = 'file'
          when /password/:        @field_type = 'password'
          when 'position':        @field_type = 'position'
          else @field_type = 'string' if @field_type == ""
        end

        # @field_type = (eval f.upcase) rescue @field_type
        @field_type = 'selector' if @field_type.class == Array
        fields_with_type << [ f, @field_type ]
        @field_type = ""

      end

      return fields_with_type

    end

    ##
    # Typus sidebar filters.
    #
    # Someday we could use something like:
    #   typus_filters :created_at, :status

    def self.typus_filters
      available_fields = self.model_fields
      fields = Typus::Configuration.config["#{self.name}"]["filters"].split(", ")
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

    ##
    #  Extended actions for this model on Typus.
    #
    # Someday we could use something like:
    #     typus_list_actions :action_one
    #     typus_form_actions :action_two, :action_three

    def self.typus_actions_for(filter)
      Typus::Configuration.config["#{self.name}"]["actions"][filter].split(", ") rescue []
    end

    ##
    # Used for +order_by+, +search+ and more ...
    #
    # Someday we could use something like:
    #     typus_search :title, :details
    #     typus_related :tags, :categories
    #     typus_order_by :title, :created_at
    #
    # Default order is ASC, except for datetime items that is DESC.

    def self.typus_defaults_for(filter)
      Typus::Configuration.config["#{self.name}"][filter].split(", ") rescue []
    end

    ##
    # Used for +relationships+
    def self.typus_relationships_for(filter)
      begin
        Typus::Configuration.config["#{self.name}"]["relationships"][filter].split(", ")
      rescue
        associations = []
        self.reflections.each do |name, value|
          associations << name.to_s if value.macro.to_s == filter
        end
        return associations
      end
    end

    def self.typus_order_by
      fields = Typus::Configuration.config["#{self.name}"]["order_by"].split(", ")
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
      name rescue "#{self.class}##{id}"
    end

  end

end
