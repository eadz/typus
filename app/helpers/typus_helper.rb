module TypusHelper

  MODELS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    @block = <<-HTML
      <title>#{Typus::Configuration.options[:app_name]} &rsaquo; #{page_title}</title>
      <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
      <meta http-equiv="imagetoolbar" content="no" />
      <meta name="description" content="" />
      <meta name="keywords" content="" />
      <meta name="author" content="" />
      <meta name="copyright" content="" />
      <meta name="generator" content="" />
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      #{stylesheet_link_tag "typus", :media => "screen"}
      #{javascript_include_tag :defaults}
    HTML
    return @block
  end

  def header
    @block = <<-HTML
    <h1>#{Typus::Configuration.options[:app_name]} #{feedback}</span></h1>
    <h2>#{Typus::Configuration.options[:app_description]}</h2>
    HTML
    return @block
  end

  def breadcrumbs
    @block = "<p>"
    if params[:model]
      @block << "<a href=\"/#{Typus::Configuration.options[:prefix]}/\">Home</a>"
      case params[:action]
      when "index"
        @block << " &rsaquo; #{params[:model].capitalize}</li>\n"
      when "edit"
        @block << " &rsaquo; <a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">#{params[:model].capitalize}</a></li>\n"
        @block << " &rsaquo; Edit</li>\n"
      when "new"
        @block << " &rsaquo; <a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">#{params[:model].capitalize}</a></li>\n"
        @block << " &rsaquo; New</li>\n"
      end
    else
      @block << "Home"
    end
    @block << "</p>"
    return @block
  end

  def modules
    @block = "<div id=\"list\">"
    @models = MODELS.to_a
    @modules = []
    @models.each { |model| @modules += model[1]['module'].to_a }
    @modules.uniq.each do |m|
      @block << "<table>\n"
      @block << "<tr><th colspan=\"2\">#{m.capitalize}</th></tr>\n"
      MODELS.each do |model|
        @block << "<tr class=\"#{cycle('even', 'odd')}\"><td><a href=\"/#{Typus::Configuration.options[:prefix]}/#{model[0].downcase.pluralize}\">#{model[0].pluralize}</a><br /><small>#{model[1]['copy']}</small></td><td align=\"right\" valign=\"bottom\"><small><a href=\"/#{Typus::Configuration.options[:prefix]}/#{model[0].downcase.pluralize}/new\">Add</a></small></td></tr>\n" if model[1]['module'] == m
      end
      @block << "</table>\n"
      @block << "<br /><div style=\"clear\"></div>"
    end
    @block << "</div>"
    return @block
  end

  def actions
    @block = "<h2>Actions</h2>\n"
    case params[:action]
    when "index"
      @block << <<-HTML
        <ul>
          <li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}/new\">Add #{params[:model].singularize.capitalize}</a></li>
        </ul>
      HTML
    when "new"
      @block << <<-HTML
        <ul>
          <li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">Back to list</a></li>
        </ul>
      HTML
    when "edit"
      @block << <<-HTML
        <ul>
          #{'<li>' + (link_to "Next #{params[:model].singularize.capitalize}", :action => "edit", :id => @next.id) + '</li>' if @next} 
          #{'<li>' + (link_to "Previous #{params[:model].singularize.capitalize}", :action => 'edit', :id => @previous.id) + '<li>' if @previous}
        </ul>
        <ul>
          <li><a href="/#{Typus::Configuration.options[:prefix]}/#{params[:model]}">Back to list</a></li>
        </ul>
      HTML
    end
    
    # More Actions
    if MODELS[@model.to_s]["actions"]
      @more_actions = ""
      @model.actions.each do |a|
        if a[1].to_s == params[:action]
          if params[:action] == "index"
            @more_actions << "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}/run?task=#{a[0]}\">#{a[0].humanize}</a></li>"
          elsif params[:action] == "edit"
            @more_actions << "<li><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}/#{params[:id]}/run?task=#{a[0]}\">#{a[0].humanize}</a></li>"
          end
        end
      end
      unless @more_actions.empty?
        @block << <<-HTML
          <h2>More Actions</h2>
          <ul>
            #{@more_actions}
          </ul>
        HTML
      end
    end
    
    return @block
  end

  def search
    if MODELS[@model.to_s]["search"]
      @search = <<-HTML
        <h2>Search</h2>
        <form action="/#{Typus::Configuration.options[:prefix]}/#{params[:model]}" method="get">
        <p><input id="query" name="query" type="text" value="#{params[:query]}"/></p>
        </form>
      HTML
    end
    return @search
  end

  def filters
    if MODELS[@model.to_s]["filters"]
      @filters = "<h2>Filter"
      @filters << " <small><a href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}\">Remove</a></small>" if request.env['QUERY_STRING']
      @filters << "</h2>"
      @model.filters.each do |f|
        case f[1]
        when "boolean"
          @filters << "<h3>By #{f[0].humanize}</h3>\n"
          @filters << "<ul>\n"
          %w( true false ).each do |status|
            @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
            @status = (@current_request.include? "#{f[0]}=#{status}") ? "on" : "off"
            @filters << "<li><a class=\"#{@status}\" href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{(@current_request.delete_if { |x| x.include? "#{f[0]}" } + ["#{f[0]}=#{status}"]).join("&")}\">#{status.capitalize}</a></li>\n"
          end
          @filters << "</ul>\n"
        when "datetime"
          @filters << "<h3>By #{f[0].humanize}</h3>\n"
          @filters << "<ul>\n"
          %w(today past_7_days this_month this_year).each do |timeline|
            @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
            @status = (@current_request.include? "#{f[0]}=#{timeline}") ? "on" : "off"
            @filters << "<li><a class=\"#{@status}\" href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{(@current_request.delete_if { |x| x.include? "#{f[0]}" } + ["#{f[0]}=#{timeline}"]).join("&")}\">#{timeline.humanize.capitalize}</a></li>\n"
          end
          @filters << "</ul>\n"
        when "collection"
          @filters << "<h3>By #{f[0].humanize}</h3>"
          @model = f[0].capitalize.constantize
          @filters << "<ul>\n"
          @model.find(:all).each do |item|
            @current_request = (request.env['QUERY_STRING']) ? request.env['QUERY_STRING'].split("&") : []
            @status = (@current_request.include? "#{f[0]}_id=#{item.id}") ? "on" : "off"
            @filters << "<li><a class=\"#{@status}\" href=\"/#{Typus::Configuration.options[:prefix]}/#{params[:model]}?#{f[0]}_id=#{item.id}\">#{item.name}</a></li>\n"
          end
          @filters << "</ul>\n"
        end
      end
    end
    return @filters
  end

  def feedback
    if flash[:notice]
      "<span id=\"notice\">#{flash[:notice]}</span>"
    elsif flash[:error]
      "<div id=\"notice\" class=\"error\">#{flash[:error]}</div>"
    end
  end

  def page_title
    "#{params[:model].capitalize if params[:model]} #{"&rsaquo;" if params[:model]} #{params[:action].capitalize if params[:action]}"
  end

  def footer
    "<p><a href=\"http://intraducibles.net/work/typus\">Typus #{Typus::Configuration.version}</a></p>"
  end

  def signature
    unless Typus::Configuration.options[:signature].blank?
      "<div id=\"signature\">#{Typus::Configuration.options[:signature]}</div>"
    end
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

  def typus_table(model = params[:model])
    @model = model.singularize.capitalize.constantize
    @block = "<table>"

    # Header of the table
    @block << "<tr>"
    @model.list_fields.each do |column|
      @order_by = "#{column[0]}#{"_id" if column[1] == 'collection'}"
      @sort_order = (params[:sort_order] == "asc") ? "desc" : "asc"
      @block << <<-HTML
        <th><a href="?order_by=#{@order_by}&sort_order=#{@sort_order}"><div class=\"#{@sort_order}\">#{column[0].humanize}</div></a></th>
      HTML
    end
    @block << "<th>&nbsp;</th>"
    @block << "</tr>"

    # Body of the table

    @items.each do |item|
      @block << "<tr class=\"#{cycle('even', 'odd')}\" id=\"item_#{item.id}\">"
      @model.list_fields.each do |column|
        case column[1]
        when 'string'
          @block << <<-HTML
            <td>#{link_to item.send(column[0]), :model => model, :action => 'edit', :id => item.id}</td>
          HTML
        when 'boolean'
          @block << <<-HTML
            <td width="20px" align="center">
              #{image_tag(status = item.send(column[0])? "typus_status_true.gif" : "typus_status_false.gif")}
              </td>
          HTML
        when "datetime"
          @block << <<-HTML
            <td width="80px">#{fmt_date(item.send(column[0]))}</td>
          HTML
        when "collection"
          this_model = column[0].capitalize.constantize
          if (this_model.new.attributes.include? 'name') || (this_model.new.methods.include? 'name')
            @block << "<td>#{item.send(column[0]).name if item.send(column[0])}</td>"
          else
            @block << "<td>#{"#{this_model}##{item.send(column[0]).id}" if item.send(column[0])}</td>"
          end
        end
      end
      
      # This controls the action to perform. If we are on a model list we 
      # will remove the entry, but if we inside a model we will remove the 
      # relationship between the models.
      case params[:model]
      when model
        @perform = link_to image_tag("typus_trash.gif"), { :model => model, :action => 'destroy', :id => item.id }, :confirm => "Remove this entry?"
      else
        @perform = link_to image_tag("typus_trash.gif"), { :action => "unrelate", :unrelated => model, :unrelated_id => item.id, :id => params[:id] }, :confirm => "Remove #{model.singularize} \"#{item.name}\" from #{params[:model].singularize}?"
      end
      @block << <<-HTML
        <td width="10px">#{@perform}</td>
        </tr>
      HTML
    end
    @block << "</table>"
  end

  def typus_form
    @block = error_messages_for :item, :header_tag => "h3"
    @form_fields.each do |field|
      @block << "<p><label>#{field[0].humanize}</label>"
      case field[1]
      when "string"
        @block << "#{text_field :item, field[0], :class => 'big'}"
      when "text"
        @block << "#{text_area :item, field[0], :rows => field[2]}"
      when "datetime"
        @block << "#{datetime_select :item, field[0]}"
      when "password"
        @block << "#{password_field :item, field[0], :class => 'big'}"
      when "boolean"
        @block << "#{check_box :item, field[0]} Checked if active"
      when "file"
        @block << "#{file_field :item, field[0], :style => 'border: 0px;'}"
      when "tags"
        @block << "#{text_field :item, field[0], :value => @item.tags.join(', '), :class => 'big'}"
      when "selector"
        @values = field[2].constantize
        @block << "#{select :item, field[0], @values.collect { |p| [ "#{p[0]} (#{p[1]})", p[1] ] }}"
      when "collection"
        @collection = field[0].singularize.capitalize.constantize
        if (@collection.new.methods.include? "name") || (@collection.new.attributes.include? 'name' )
          @block << "#{collection_select :item, "#{field[0]}_id", @collection.find(:all), :id, :name, :include_blank => true}"
        else
          @block << "#{select :item, "#{field[0]}_id", @collection.find(:all).collect { |p| ["#{@collection}##{p.id}", p.id] }, :include_blank => true}"
        end
      when "multiple"
        multiple = field[0].singularize.capitalize.constantize
        rel_model = "#{field[0].singularize}_id"
        current_model = params[:model].singularize.capitalize.constantize
        @selected = current_model.find(params[:id]).send(field[0]).collect { |t| t.send(rel_model).to_i } if params[:id]
        @block << <<-HTML
          <select name="item[tag_ids][]" multiple="multiple">
            #{options_from_collection_for_select(multiple.find(:all), :id, :name, @selected)}
          </select>
        HTML
      else
        @block << "Unexisting"
      end
      @block << "</p>"
    end
    return @block
  end

  # TODO: Don't show form if there are not more Items available.
  def typus_form_externals
    @block = ""
    @form_fields_externals.each do |field|
      model_to_relate = field[0].singularize.capitalize.constantize
      @block << <<-HTML
        <h2 style="margin: 20px 0px 10px 0px;">#{field[0].capitalize} <small><a href="/#{Typus::Configuration.options[:prefix]}/#{field[0]}/new?back_to=#{params[:model]}&item_id=#{params[:id]}">Add new</a></small></h2>
      HTML
      
      @items_to_relate = (model_to_relate.find(:all) - @item.send(field[0]))
        
      if @items_to_relate.size > 0
        @block << <<-HTML
          #{form_tag :action => "relate", :related => "#{field[0]}", :id => params[:id]}
          <p>#{select "model_id_to_relate", :related_id, @items_to_relate.map { |f| [f.name, f.id] }}
        &nbsp; #{submit_tag "Add"}</p>
          </form>
        HTML
      end
      current_model = params[:model].singularize.capitalize.constantize
      @items = current_model.find(params[:id]).send(field[0])
      @block << typus_table(field[0]) if @items.size > 0
    end
    return @block
  end

  def process_query(query)
    if params[:query]
      @query = "Search results on <strong>#{params[:model]}</strong> "
      @query << "for <strong>\"#{params[:query]}\"</strong>"
    end
    return @query
  end

end