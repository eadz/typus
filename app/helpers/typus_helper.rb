module TypusHelper

  MODELS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    @block = "<title>#{Typus::Configuration.options[:app_name]} &rsaquo; #{page_title}</title>\n"
    @block += "<link rel=\"shortcut icon\" href=\"/favicon.ico\" type=\"image/x-icon\" />\n"
    @block += "<meta http-equiv=\"imagetoolbar\" content=\"no\" />\n"
    @block += "<meta name=\"description\" content=\"\" />\n"
    @block += "<meta name=\"keywords\" content=\"\" />\n"
    @block += "<meta name=\"author\" content=\"\" />\n"
    @block += "<meta name=\"copyright\" content=\"\" />\n"
    @block += "<meta name=\"generator\" content=\"\" />\n"
    @block += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
    @block += stylesheet_link_tag "typus", :media => "screen"
    @block += "\n"
    @block += javascript_include_tag :defaults
    return @block
  end

  def header
    @block += "<h1>#{Typus::Configuration.options[:app_name]}"
    @block += "<span class=\"feedback\">#{flash[:notice]}</span>" if flash[:notice]
    @block += "</h1>\n"
    @block += "<h2>#{Typus::Configuration.options[:app_description]}</h2>\n"
    return @block
  end

  def breadcrumbs
    @block = "<p>"
    if params[:model]
      @block += "<a href=\"/#{Typus::Configuration.options[:prefix]}/\">Home</a>"
      case params[:action]
      when "index"
        @block += " &rsaquo; #{params[:model].capitalize}</li>\n"
      when "edit"
        @block += " &rsaquo; <a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">#{params[:model].capitalize}</a></li>\n"
        @block += " &rsaquo; Edit</li>\n"
      when "new"
        @block += " &rsaquo; <a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">#{params[:model].capitalize}</a></li>\n"
        @block += " &rsaquo; New</li>\n"
      end
    else
      @block += "Home"
    end
    @block += "</p>"
    return @block
  end

  def modules
    @block = "<div id=\"list\">"
    @models = MODELS.to_a
    @modules = []
    @models.each { |model| @modules += model[1]['module'].to_a }
    @modules.uniq.each do |m|
      @block += "<table>\n"
      @block += "<tr><th colspan=\"2\">#{m.capitalize}</th></tr>\n"
      MODELS.each do |model|
        @block += "<tr class=\"#{cycle('even', 'odd')}\"><td><a href=\"/#{Typus::Configuration.options[:prefix]}/#{model[0].downcase.pluralize}\">#{model[0].pluralize}</a><br /><small>#{model[1]['copy']}</small></td><td align=\"right\" valign=\"bottom\"><small><a href=\"/#{Typus::Configuration.options[:prefix]}/#{model[0].downcase.pluralize}/new\">Add</a></small></td></tr>\n" if model[1]['module'] == m
      end
      @block += "</table>\n"
      @block += "<br /><div style=\"clear\"></div>"
    end
    @block += "</div>"
    return @block
  end

  def sidebar
    @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
    
    @block = ""
    
    if params[:model]
      @model = eval params[:model].singularize.capitalize
      
      # Default Actions
      @block += "<h2>Actions</h2>\n"
      case params[:action]
      when "index"
        @block += "<ul>\n"
        @block += "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}/new\">Add new #{params[:model].singularize}</a></li>\n"
        @block += "</ul>\n"
      when "new"
        @block += "<ul>\n"
        @block += "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">Back to list</a></li>\n"
        @block += "</ul>\n"
      when "edit"
        @block += "<ul>\n"
        @block += "<li>#{link_to "Next #{params[:model].singularize}", :action => "edit", :id => @next.id}</li>" if @next
        @block += "<li>#{link_to "Previous #{params[:model].singularize}", :action => 'edit', :id => @previous.id}</li>" if @previous
        @block += "</ul>\n"
        @block += "<ul>\n"
        @block += "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">Back to list</a></li>\n"
        @block += "</ul>\n"
      end
      
      # Extra Actions
      if MODELS[@model.to_s]["actions"]
        @block += "<h2>More Actions</h2>"
        @block += "<ul>"
        @model.actions.each { |a| @block += "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}/#{a[0]}\">#{a[0].humanize}</a></li>" if a[1] == params[:action] }
        @block += "</ul>"
      end
      
      # Search
      if params[:action] == "index"
        if MODELS[@model.to_s]["search"]
          @block += "<h2>Search</h2>\n"
          @block += "<form action=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\" method=\"get\">"
          @block += "<p><input id=\"query\" name=\"query\" type=\"text\" value=\"#{params[:query]}\"/></p>"
          @block += "</form>"
        end
      end
      
      # Filters (only shown on index page)
      if params[:action] == "index"
        if MODELS[@model.to_s]["filters"]
          @block += "<h2>Filter"
          @block += " <small><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">Remove</a></small>" if request.env['QUERY_STRING']
          @block += "</h2>"
          @model.filters.each do |f|
            case f[1]
            when "boolean"
              @filters = %w( true false )
              @block += "<h3>By #{f[0].humanize}</h3>\n"
              @block += "<ul>\n"
              @filters.each do |status|
                @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
                @status = (@current_request.include? "#{f[0]}=#{status}") ? "on" : "off"
                @block += "<li><a class=\"#{@status}\" href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{(@current_request.delete_if { |x| x.include? "#{f[0]}" } + ["#{f[0]}=#{status}"]).join("&")}\">#{status.capitalize}</a></li>\n"
              end
              @block += "</ul>\n"
            when "datetime"
              @filters = %w(today past_7_days this_month this_year)
              @block += "<h3>By #{f[0].humanize}</h3>\n"
              @block += "<ul>\n"
              @filters.each do |timeline|
                @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
                @status = (@current_request.include? "#{f[0]}=#{timeline}") ? "on" : "off"
                @block += "<li><a class=\"#{@status}\" href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{(@current_request.delete_if { |x| x.include? "#{f[0]}" } + ["#{f[0]}=#{timeline}"]).join("&")}\">#{timeline.humanize.capitalize}</a></li>\n"
              end
              @block += "</ul>\n"
            when "collection"
              @block += "<h3>By #{f[0].humanize}</h3>"
              @model = eval f[0].capitalize
              @block += "<ul>\n"
              @model.find(:all).each { |item| @block += "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{f[0]}_id=#{item.id}\">#{item.name}</a></li>\n" }
              @block += "</ul>\n"
            end
          end
        end
      end
    end
    return @block
  rescue
    return "FixMe: <strong>typus.yml</strong>"
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
    @block = "<p><a href=\"http://intraducibles.net/work/typus\">Typus #{Typus::Configuration.version}</a></p>"
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

  def typus_form
    @block = ""
    @block += error_messages_for :item, :header_tag => "h3"
    @form_fields.each do |field|
      @block += "<p><label>#{field[0].humanize}</label>"
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
        @values = eval field[2]
        @block += select :item, field[0], @values.collect { |p| [ "#{p[0]} (#{p[1]})", p[1] ] }
      when "collection"
        @collection = eval field[0].singularize.capitalize
        if @collection.new.methods.include? "name"
          @block += collection_select :item, "#{field[0]}_id", @collection.find(:all), :id, :name, :include_blank => true
        else
          @block += select :item, "#{field[0]}_id", @collection.find(:all).collect { |p| ["#{@collection}##{p.id}", p.id] }, :include_blank => true
        end
      when "multiple"
        multiple = eval field[0].singularize.capitalize
        rel_model = "#{field[0].singularize}" + "_id"
        current_model = eval params[:model].singularize.capitalize
        @selected = current_model.find(params[:id]).send(field[0]).collect { |t| t.send(rel_model).to_i } if params[:id]
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
      @block += "</form>"
      current_model = eval params[:model].singularize.capitalize
      items = current_model.find(params[:id]).send(field[0])
      @block += "<ul>"
      items.each { |item| @block += "<li>#{item.name} <small>#{link_to "Remove", :action => "unrelate", :unrelated => field[0], :unrelated_id => item.id, :id => params[:id]}</small></li>" }
      @block += "</ul>"
    end
    return @block
  end

  def process_query(query)
    @query = ""
    query.split("&").each do |q|
      @query += "<strong>#{q.split("=")[0].humanize.downcase}</strong> is <strong>#{q.split("=")[1].humanize.downcase}</strong>, "
    end
    return @query
  end

end