module TypusHelper

  MODELS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    @block = "<title>#{TYPUS['app_name']} &rsaquo; #{page_title}</title>\n"
    @block += "<link rel=\"shortcut icon\" href=\"/favicon.ico\" type=\"image/x-icon\" />\n"
    @block += "<meta http-equiv=\"imagetoolbar\" content=\"no\" />\n"
    @block += "<meta name=\"description\" content=\"\" />\n"
    @block += "<meta name=\"keywords\" content=\"\" />\n"
    @block += "<meta name=\"author\" content=\"\" />\n"
    @block += "<meta name=\"copyright\" content=\"\" />\n"
    @block += "<meta name=\"generator\" content=\"\" />\n"
    @block += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
    @block += stylesheet_link_tag "typus/admin", :media => "screen"
    @block += "\n"
    @block += javascript_include_tag :defaults
    return @block
  end

  def header
    @block = "<h1>#{TYPUS['app_name']} <span class=\"feedback\">#{flash[:notice]}</span></h1>\n"
    @block += "<h2>#{TYPUS['app_description']}</h2>"
    return @block
  end

  def breadcrumbs
    @block = ""
    if params[:model]
      @block += "<p>"
      @block += "<a href=\"/#{TYPUS['prefix']}/\">Home</a>"
      if params[:action] == "index"
        @block += " &rsaquo; #{params[:model].capitalize}</li>\n"
      else
        @block += " &rsaquo; <a href=\"/#{TYPUS['prefix']}/#{params[:model]}\">#{params[:model].capitalize}</a></li>\n"
      end
      if params[:action] == "edit"
        @block += " &rsaquo; Edit</li>\n"
      end
      if params[:action] == "new"
        @block += " &rsaquo; New</li>\n"
      end
      @block += "</p>"
    end
    return @block
  end

  def modules
    @block = "<ul>\n"
    MODELS.each { |model| @block += "<li><a href=\"/#{TYPUS['prefix']}/#{model[0].downcase.pluralize}\">#{model[0].pluralize}</a> <small><a href=\"/#{TYPUS['prefix']}/#{model[0].downcase.pluralize}/new\">Add</a></small></li>\n" }
    @block += "</ul>\n"
    return @block
  rescue
    return "<ul><li>FixMe: <strong>typus.yml</strong></li></ul>"
  end

  def sidebar
    if params[:model]
      @model = params[:model].singularize.capitalize
      @model = MODELS[@model]
      @block = ""
      # Actions
      @block += "<h2>Actions</h2>\n"
      @block += "<ul>\n"
      @block += "<li><a href=\"/#{TYPUS['prefix']}/#{params[:model]}/new\">Add new #{params[:model].singularize}</a></li>\n"
      # @block += "<li>Search</li>\n"
      # @block += "#{link_to_function "Search", "['search_box'].each(Element.toggle);"}" # if @model.search_fields.size > 0
      # PREVIOUS AND NEXT
      @block += "</ul>\n"
      @block += "<ul>\n"
      @block += "<li>#{link_to "Next #{params[:model].singularize}", :action => "edit", :id => @next.id}</li>" if @next
      @block += "<li>#{link_to "Previous #{params[:model].singularize}", :action => 'edit', :id => @previous.id}</li>" if @previous
      @block += "</ul>\n"
      # Actions end
      if @model["filters"]
        @block += "<h2>Filter</h2>"
        # @model.filters ...
        Post.filters.each do |f|
          if f[1] == "boolean"
            @block += "<h3>By #{f[0].humanize}</h3>\n"
            @block += "<ul>\n"
            @status = params[:filter_id] == "true" ? "on" : "off"
            @block += "<li><a class=\"#{@status}\" href=\"/#{TYPUS['prefix']}/#{params[:model]}?filter_by=#{f[0]}&filter_id=true\">Active</a></li>\n"
            @status = params[:filter_id] == "false" ? "on" : "off"
            @block += "<li><a class=\"#{@status}\" href=\"/#{TYPUS['prefix']}/#{params[:model]}?filter_by=#{f[0]}&filter_id=false\">Inactive</a></li>\n"
            @block += "</ul>\n"
          elsif f[1] == "datetime"
            @block += "<h3>By #{f[0].humanize}</h3>\n"
            @block += "<ul>\n"
            %w( today past_7_days this_month this_year).each do |timeline|
              @status = params[:filter_id] == timeline ? "on" : "off"
              @block += "<li><a class=\"#{@status}\" href=\"/#{TYPUS['prefix']}/#{params[:model]}?filter_by=#{f[0]}&filter_id=#{timeline}\">#{timeline.humanize.capitalize}</a></li>\n"
            end
            @block += "</ul>\n"
          elsif f[1] == "collection"
            @block += "<h3>By #{f[0].humanize}</h3>"
            @model = eval f[0].capitalize
            @block += "<ul>\n"
            @model.find(:all).each do |item|
              @block += "<li><a href=\"/#{TYPUS['prefix']}/#{params[:model]}?filter_by=#{f[0]}_id&filter_id=#{item.id}\">#{item.name}</a></li>\n"
            end
            @block += "</ul>\n"
          end
        end
      end
    end
    return @block
#  rescue
#    return "FixMe: <strong>typus.yml</strong>"
  end

  def feedback
    if flash[:notice]
      "<div id=\"notice\">#{flash[:notice]}</div>"
    elsif flash[:error]
      "<div id=\"notice-error\">#{flash[:error]}</div>"
    end
  end

  def page_title
    "#{params[:model].capitalize if params[:model]} #{"&rsaquo;" if params[:model]} #{params[:action].capitalize if params[:action]}"
  end

  def footer
    @block = "<p><a href=\"http://intraducibles.net/work/typus\">Typus #{TYPUS["Typus"]["version"]}</a></p>"
    return @block
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

  def typus_form
    @block = ""
    @form_fields.each do |field|
      @block += "<p><label>#{field[0].humanize} #{error_message_on :item, field[0]}</label>"
      case field[1]
      when "string"
        @block += text_field :item, field[0], :class => "big"
      when "text"
        @block += text_area :item, field[0], :rows => "#{field[2]}"
      when "datetime"
        @block += datetime_select :item, field[0]
      when "password"
        @block += password_field :item, field[0], :class => "big"
      when "boolean"
        @block += "#{check_box :item, field[0]} Checked if active"
      when "file"
        @block += file_field :item, field[0], :style => "border: 0px;"
      when "tags"
        @block += text_field :item, field[0], :value => @item.tags.join(", "), :class => "big"
      when "selector"
        @values = LANGUAGES
        @block += select :item, field[0], @values.collect { |p| [ "#{p[0]} (#{p[1]})", p[1] ] }
      when "collection"
        @collection = eval field[0].singularize.capitalize
        @block += collection_select :item, "#{field[0]}_id", @collection.find(:all), :id, :name, :include_blank => true
      when "multiple"
        multiple = eval field[0].singularize.capitalize
        rel_model = "#{field[0].singularize}" + "_id"
        current_model = eval params[:model].singularize.capitalize
        if params[:id]
          @selected = current_model.find(params[:id]).send(field[0]).collect { |t| t.send(rel_model).to_i }
        end
        @block += "<select name=\"item[tag_ids][]\" multiple=\"multiple\">"
        @block += options_from_collection_for_select(multiple.find(:all), :id, :name, @selected)
        @block += "</select>"
      else
        @block += "Unexisting"
      end
      @block += "</p>"
    end
    return @block
  end

  def typus_form_externals
    @block = ""
    @form_fields_externals.each do |field|
      model_to_relate = eval field[0].singularize.capitalize
      
      @block += "<h2 style=\"margin: 20px 0px 0px 0px;\">#{field[0].capitalize}</h2>"
      @block += form_tag :action => "relate", :related => "#{field[0]}"
      @block += "<p>"
      @block += select "model_id_to_relate", :related_id, (model_to_relate.find(:all) - @item.send(field[0])).map { |f| [f.name, f.id] }
      @block += "&nbsp; #{submit_tag "Add #{field[0].singularize}"}</p>"
      current_model = eval params[:model].singularize.capitalize
      items = current_model.find(params[:id]).send(field[0])
      @block += "<ul>"
      items.each do |item|
        @block += "<li>#{item.name} <small>#{link_to "Remove", :action => "unrelate", :unrelated => field[0], :unrelated_id => item.id, :id => params[:id]}</small></li>"
      end
      @block += "</ul>"
      
    end
    return @block
  end

end