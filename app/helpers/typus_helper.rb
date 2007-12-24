module TypusHelper

  MODELS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    html = <<-HTML
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
  end

  def header
    html = <<-HTML
      <h1>#{Typus::Configuration.options[:app_name]} #{feedback}</span></h1>
      <h2>#{Typus::Configuration.options[:app_description]}</h2>
    HTML
  end

  def breadcrumbs
    html = "<p>"
    if params[:model]
      html << "<a href=\"/#{Typus::Configuration.options[:prefix]}/\">Home</a>"
      case params[:action]
      when "index"
        html << " &rsaquo; #{params[:model].capitalize}\n"
      when "new", "edit"
        html << " &rsaquo; #{link_to params[:model].capitalize, :action => 'index'} &rsaquo; #{params[:action].capitalize}"
      end
    else
      html << "Home"
    end
    html << "</p>"
  end

  # Dashboard list of modules
  def modules
    html = "<div id=\"list\">"
    modules = []
    MODELS.to_a.each { |model| modules << ((model[1].has_key? 'module') ? model[1]['module'].capitalize : 'Typus') }
    modules.uniq.each do |m|
      html << "<table>\n"
      html << "<tr><th colspan=\"2\">#{m.capitalize}</th></tr>\n"
      MODELS.each do |model|
        current = (model[1]['module']) ? model[1]['module'].capitalize : 'Typus'
        if current == m
          html << "<tr class=\"#{cycle('even', 'odd')}\"><td>"
          html << "#{link_to model[0].pluralize, :action => 'index', :model => model[0].downcase.pluralize}<br />"
          html << "<small>#{model[1]['description']}</small></td>"
          html << "<td align=\"right\" valign=\"bottom\"><small>"
          html << "#{link_to 'Add', :action => 'new', :model => model[0].downcase.pluralize}"
          html << "</small></td></tr>\n"
        end
      end
      html << "</table>\n<br /><div style=\"clear\"></div>"
    end
    html << "</div>"
  end

  def actions
    html = "<h2>Actions</h2>\n"
    case params[:action]
    when "index"
      html << "<ul>"
      html << "<li>#{link_to "Add #{params[:model].singularize.capitalize}", :action => 'new'}</li>"
      html << "</ul>"
      html << more_actions
    when "new"
      html << "<ul>"
      html << "<li>#{link_to "Back to list", :action => 'index'}</li>"
      html << "</ul>"
    when "edit"
      html << "<ul>"
      html << "#{'<li>' + (link_to "Next", :action => "edit", :id => @next.id) + '</li>' if @next}"
      html << "#{'<li>' + (link_to "Previous", :action => 'edit', :id => @previous.id) + '<li>' if @previous}"
      html << "</ul>"
      html << more_actions
      html << "<ul>"
      html << "<li>#{link_to "Back to list", :action => 'index'}</li>"
      html << "</ul>"
    end
  end

  def more_actions
    html = ""
    case params[:action]
    when 'index'
      a = 'list'
    when 'edit'
      a = 'form'
    end
    @model.typus_actions_for(a).each { |a| html << "<li>#{link_to a.humanize, :action => 'run', :task => a}</li>" }
    html = "<ul>#{html}</ul>" if html
  end

  def search
    if MODELS["#{@model}"]["search"]
      search = <<-HTML
        <h2>Search</h2>
        <form action="" method="get">
        <p><input id="search" name="search" type="text" value="#{params[:search]}"/></p>
        </form>
      HTML
    end
  end

  def filters
    current_request = request.env['QUERY_STRING'] || []
    if @model.typus_filters.size > 0
      html = "<h2>Filter <small>"
      html << "#{link_to "Remove", :action => 'index'}" if current_request.size > 0
      html << "</small></h2>"
      @model.typus_filters.each do |f|
        case f[1]
        when 'boolean'
          html << "<h3>By #{f[0].humanize}</h3>\n"
          html << "<ul>\n"
          %w( true false ).each do |status|
            switch = (current_request.include? "#{f[0]}=#{status}") ? 'on' : 'off'
            html << "<li>#{link_to status.capitalize, { :params => params.merge(f[0] => status) }, :class => switch}</li>"
          end
          html << "</ul>\n"
        when 'datetime'
          html << "<h3>By #{f[0].humanize}</h3>\n<ul>\n"
          %w(today past_7_days this_month this_year).each do |timeline|
            switch = (current_request.include? "#{f[0]}=#{timeline}") ? 'on' : 'off'
            html << "<li>#{link_to timeline.humanize.capitalize, { :params => params.merge(f[0] => timeline) }, :class => switch}</li>"
          end
          html << "</ul>\n"
        when 'integer'
          model = f[0].split("_id").first.capitalize.constantize
          if model.count > 0
            html << "<h3>By #{f[0].humanize}</h3>\n<ul>\n"
            model.find(:all).each do |item|
              switch = (current_request.include? "#{f[0]}=#{item.id}") ? 'on' : 'off'
              html << "<li>#{link_to item.name, { :params => params.merge(f[0] => item) }, :class => switch}</li>"
            end
            html << "</ul>\n"
          end
        end
      end
    end
    return html
  end

  def feedback
    if flash[:notice]
      "<span id=\"notice\">#{flash[:notice]}</span>"
    elsif flash[:error]
      "<div id=\"notice\" class=\"error\">#{flash[:error]}</div>"
    end
  end

  def page_title
    html = ""
    html << "#{params[:model].capitalize} &rsaquo; " if params[:model]
    html << "#{params[:action].capitalize}" if params[:action]
  end

  def footer
    "<p>#{link_to "Typus", "http://intraducibles.net/projects/typus"}</p>"
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
    html = "<table>"
    
    # Header of the table
    html << "<tr>"
    @model.typus_fields_for('list').each do |column|
      order_by = "#{column[0]}#{"_id" if column[1] == 'collection'}"
      sort_order = (params[:sort_order] == "asc") ? "desc" : "asc"
      html << "<th>#{link_to "<div class=\"#{sort_order}\">#{column[0].humanize}</div>", { :params => params.merge( :order_by => order_by, :sort_order => sort_order) }}</th>"
    end
    html << "<th>&nbsp;</th>\n</tr>"
    
    # Body of the table
    
    @items.each do |item|
      html << "<tr class=\"#{cycle('even', 'odd')}\" id=\"item_#{item.id}\">"
      @model.typus_fields_for('list').each do |column|
        case column[1]
        when 'string', 'integer'
          html << "<td>#{link_to item.send(column[0]), :model => model, :action => 'edit', :id => item.id}</td>"
        when 'boolean'
          html << "<td width=\"20px\" align=\"center\">#{image_tag(status = item.send(column[0])? "typus_status_true.gif" : "typus_status_false.gif")}</td>"
        when "datetime"
          html << "<td width=\"80px\">#{fmt_date(item.send(column[0]))}</td>"
        when "selector"
          this_model = column[0].split("_id").first.capitalize.constantize
          if (this_model.new.methods.include? 'name')
            html << "<td>#{item.send(column[0].split("_id").first).name if item.send(column[0])}</td>"
          else
            html << "<td>#{"#{this_model}##{item.send(column[0]).id}" if item.send(column[0])}</td>"
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
      html << "<td width=\"10px\">#{@perform}</td>\n</tr>"
    end
    html << "</table>"
  end

  def typus_form
    html = error_messages_for :item, :header_tag => "h3"
    @form_fields.each do |field|
      case field[0] # Field Name
      when 'uploaded_data'
        html << "<p><label>Upload File</label>"
      else
        html << "<p><label>#{field[0].humanize}</label>"
      end
      case field[1] # Field Type
      when "boolean"
        html << "#{check_box :item, field[0]} Checked if active"
      when "blob"
        html << "#{file_field :item, field[0], :style => 'border: 0px;'}"
      when "datetime"
        html << "#{datetime_select :item, field[0]}"
      when "password"
        html << "#{password_field :item, field[0], :class => 'big'}"
      when "string"
        html << "#{text_field :item, field[0], :class => 'big'}"
      when "text"
        html << "#{text_area :item, field[0], :rows => field[2] || '10'}"
      when "selector"
        values = eval field[0].upcase
        html << "#{select :item, field[0], values.collect { |p| [ "#{p[0]} (#{p[1]})", p[1] ] }, :include_blank => true}"
      when "collection"
        related = field[0].split("_id").first.capitalize.constantize
        if related.new.methods.include? 'name'
          html << "#{collection_select :item, "#{field[0]}", related.find(:all), :id, :name, :include_blank => true}"
        else
          html << "#{select :item, "#{field[0]}", related.find(:all).collect { |p| ["#{related}##{p.id}", p.id] }, :include_blank => true}"
        end
      end
      html << "</p>"
    end
    return html
  end

  # TODO: Don't show form if there are not more Items available.
  def typus_form_externals
    html = ""
    @form_fields_externals.each do |field|
      model_to_relate = field.singularize.capitalize.constantize
      html << "<h2 style=\"margin: 20px 0px 10px 0px;\">#{field.capitalize}</h2>"
      items_to_relate = (model_to_relate.find(:all) - @item.send(field))
      if items_to_relate.size > 0
        html << <<-HTML
          #{form_tag :action => "relate", :related => field, :id => params[:id]}
          <p>#{select "model_id_to_relate", :related_id, items_to_relate.map { |f| [f.name, f.id] }}
        &nbsp; #{submit_tag "Add"}</p>
          </form>
        HTML
      end
      current_model = params[:model].singularize.capitalize.constantize
      @items = current_model.find(params[:id]).send(field)
      html << typus_table(field) if @items.size > 0
    end
    return html
  rescue
    ""
  end

  def process_query(q)
    if params[:search]
      query = "Search results on <strong>#{params[:model]}</strong> "
      query<< "for <strong>\"#{params[:search]}\"</strong>"
    end
    return query
  end

end