module TypusHelper

  MODELS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    html = <<-HTML
      <title>#{Typus::Configuration.options[:app_name]} #{page_title}</title>
      <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
      <meta http-equiv="imagetoolbar" content="no" />
      <meta name="description" content="" />
      <meta name="keywords" content="" />
      <meta name="author" content="" />
      <meta name="copyright" content="" />
      <meta name="generator" content="" />
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      #{stylesheet_link_tag "typus", :media => "screen"}
      #{stylesheet_link_tag "lightview", :media => "screen"}
      #{javascript_include_tag :defaults}
      <script type=\"text/javascript\" src=\"/javascripts/prototype.js\"></script>
      <script type=\"text/javascript\" src=\"/javascripts/scriptaculous.js?load=effects\"></script>
      <script type=\"text/javascript\" src=\"/javascripts/lightview.js\"></script>
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
      html << "#{link_to "Home", typus_dashboard_url}" 
      case params[:action]
      when "index"
        html << " &rsaquo; #{params[:model].titleize}\n"
      when "new", "edit"
        html << " &rsaquo; #{link_to params[:model].titleize, :action => 'index'} &rsaquo; #{params[:action].titleize}"
      end
    else
      html << "Home"
    end
    html << "</p>"
  end

  def login_info
    html = "<ul>"
    if session[:typus].class == TypusUser
      html << "<li>#{session[:typus].email} (#{session[:typus].role}) </li>"
    end
    html << "<li>#{link_to "View Site", '/', :target => 'blank'}</li>"
    html << "<li>#{link_to "Logout", typus_logout_url}</li>"
    html << "</ul>"
    return html
  end

  # Dashboard list of modules
  def modules
    html = "<div id=\"list\">"
    modules = []
    MODELS.to_a.each { |model| modules << ((model[1].has_key? 'module') ? model[1]['module'].capitalize : 'Typus') }
    modules.uniq.each do |m|
      html << "<table>\n"
      html << "<tr><th colspan=\"2\">#{m.titleize}</th></tr>\n"
      
      if Typus::Configuration.options[:username] && Typus::Configuration.options[:password]
        @models = MODELS
      else
        @user = TypusUser.find(session[:typus].id)
        @models = Hash.new
        @user.models.each { |mo| @models["#{mo}"] = Typus::Configuration.config["#{mo}"] }
      end
      
      @models.each do |model|
        current = (model[1]['module']) ? model[1]['module'].capitalize : 'Typus'
        if current == m
          html << "<tr class=\"#{cycle('even', 'odd')}\"><td>"
          html << "#{link_to model[0].pluralize, :action => 'index', :model => model[0].to_s.delete(" ").tableize}<br />"
          html << "<small>#{model[1]['description']}</small></td>"
          html << "<td align=\"right\" valign=\"bottom\"><small>"
          html << "#{link_to 'Add', :action => 'new', :model => model[0].to_s.delete(" ").tableize}"
          html << "</small></td></tr>\n"
        end
      end
      html << "</table>\n<br /><div style=\"clear\"></div>"
    end
    html << "</div>"
  rescue
    "There was an error when loading <code>config/typus.yml</code>."
  end

  def actions
    html = "<h2>Actions</h2>\n"
    case params[:action]
    when "index"
      html << "<ul>"
      html << "<li>#{link_to "Add #{params[:model].titleize.singularize}", :action => 'new'}</li>"
      html << "</ul>"
      html << more_actions
    when "new", "create"
      html << "<ul>"
      html << "<li>#{link_to "Back to list", :action => 'index'}</li>"
      html << "</ul>"
    when "edit", "update"
      html << "<ul>"
      html << "<li>#{link_to "Add #{params[:model].titleize.singularize}", :action => 'new'}</li>"
      html << "</ul>"
      html << "<ul>"
      html << "#{'<li>' + (link_to "Next", :action => "edit", :id => @next.id) + '</li>' if @next}"
      html << "#{'<li>' + (link_to "Previous", :action => 'edit', :id => @previous.id) + '<li>' if @previous}"
      html << "</ul>"
      html << more_actions
      html << "<ul>"
      html << "<li>#{link_to "Back to list", :action => 'index'}</li>"
      html << "</ul>"
    else
      html << more_actions
      html << "<ul>"
      if params[:id]
        html << "<li>#{link_to "Back to list", :controller => 'typus', :action => 'edit', :id => params[:id]}</li>"
      else
        html << "<li>#{link_to "Back to list", :controller => 'typus', :action => 'index'}</li>"
      end
      html << "</ul>"
    end
  end

  def more_actions
    html = ""
    case params[:action]
    when 'index'
      @model.typus_actions_for('list').each { |a| html << "<li>#{link_to a.titleize, :controller => 'typus_extras', :model => params[:model], :action => a }</li>" }
    when 'edit'
      @model.typus_actions_for('form').each { |a| html << "<li>#{link_to a.titleize, :controller => 'typus_extras', :model => params[:model], :action => a, :id => params[:id] }</li>" }
    end
    html = "<ul>#{html}</ul>" if html
  end

  def search
    the_model = (@model.to_s.tableize.singularize.split("_").each { |i| i.capitalize! }).join(" ")
    if MODELS["#{the_model}"]["search"]
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
          html << "<h3>By #{f[0].titleize}</h3>\n"
          html << "<ul>\n"
          %w( true false ).each do |status|
            switch = (current_request.include? "#{f[0]}=#{status}") ? 'on' : 'off'
            html << "<li>#{link_to status.capitalize, { :params => params.merge(f[0] => status) }, :class => switch}</li>"
          end
          html << "</ul>\n"
        when 'datetime'
          html << "<h3>By #{f[0].titleize}</h3>\n<ul>\n"
          %w(today past_7_days this_month this_year).each do |timeline|
            switch = (current_request.include? "#{f[0]}=#{timeline}") ? 'on' : 'off'
            html << "<li>#{link_to timeline.titleize, { :params => params.merge(f[0] => timeline) }, :class => switch}</li>"
          end
          html << "</ul>\n"
        when 'integer'
          model = f[0].split("_id").first.capitalize.constantize
          if model.count > 0
            html << "<h3>By #{f[0].humanize}</h3>\n<ul>\n"
            model.find(:all).each do |item|
              switch = (current_request.include? "#{f[0]}=#{item.id}") ? 'on' : 'off'
              html << "<li>#{link_to item.name, { :params => params.merge(f[0] => item.id) }, :class => switch}</li>"
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
    html << " &rsaquo; #{params[:model].titleize}" if params[:model]
    html << " &rsaquo; #{params[:action].titleize}" if params[:action]
    return html
  end

  def footer
    %{<p>#{link_to "Typus #{Typus::Configuration.options[:version]}", "http://intraducibles.net/projects/typus"}</p>}
  end

  def signature
    unless Typus::Configuration.options[:signature].blank?
      "<div id=\"signature\">#{Typus::Configuration.options[:signature]}</div>"
    end
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

  def typus_table(model = params[:model], fields = 'list')

    @model = model.camelize.singularize.constantize
    html = "<table>"

    # Header of the table
    html << "<tr>"
    @model.typus_fields_for(fields).each do |column|
      order_by = column[0]
      sort_order = (params[:sort_order] == "asc") ? "desc" : "asc"
      html << "<th>#{link_to "<div class=\"#{sort_order}\">#{column[0].titleize}</div>", { :params => params.merge( :order_by => order_by, :sort_order => sort_order) }}</th>"
    end
    html << "<th>&nbsp;</th>\n</tr>"
    
    # Body of the table
    @items.each do |item|
      html << "<tr class=\"#{cycle('even', 'odd')}\" id=\"item_#{item.id}\">"
      @model.typus_fields_for('list').each do |column|
        case column[1]
        when 'boolean'
          image = "#{image_tag(status = item.send(column[0])? "typus_status_true.gif" : "typus_status_false.gif")}"
          if column[0] == 'status'
            html << "<td width=\"20px\" align=\"center\">#{link_to image, :controller => 'typus', :model => model, :action => 'status', :id => item.id}</td>"
          else
            html << "<td width=\"20px\" align=\"center\">#{image}</td>"
          end
        when "datetime"
          html << "<td width=\"80px\">#{fmt_date(item.send(column[0]))}</td>"
        when "collection"
          this_model = column[0].split("_id").first.capitalize.constantize
          if (this_model.new.methods.include? 'name') || (this_model.new.attributes.keys.include? 'name')
            html << "<td>#{item.send(column[0].split("_id").first).name if item.send(column[0])}</td>"
          else
            html << "<td>#{"#{this_model}##{item.send(column[0])}" if item.send(column[0])}</td>"
          end
        when 'tree'
          html << "<td>#{item.parent.name if item.parent}</td>"
        when 'preview'
          if item.content_type.include? "image"
            html << "<td>#{lightview_image_tag item.public_filename, :title => item.filename}</td>"
          else
            html << "<td>#{link_to "Download", item.public_filename}</td>"
          end
        when "position"
          html << "<td>#{link_to "Up", :model => model, :action => 'position', :id => item, :go => 'up'} / #{link_to "Down", :model => model, :action => 'position', :id => item, :go => 'down'} (#{item.send(column[0])})</td>"
        else # 'string', 'integer', 'selector'
          html << "<td>#{link_to item.send(column[0]), :model => model, :action => 'edit', :id => item.id}</td>"
        end
      end
      
      # This controls the action to perform. If we are on a model list we 
      # will remove the entry, but if we inside a model we will remove the 
      # relationship between the models.
      case params[:model]
      when model
        # Remove the current action, to be able to set the new one
        params.delete('action')
        @perform = link_to image_tag("typus_trash.gif"), { :model => model, :action => 'destroy', :id => item.id, :params => params }, :confirm => "Remove this entry?"
      else
        @perform = link_to image_tag("typus_trash.gif"), { :action => "unrelate", :unrelated => model, :unrelated_id => item.id, :id => params[:id] }, :confirm => "Remove #{model.singularize} \"#{item.name}\" from #{params[:model].singularize}?"
      end
      html << "<td width=\"10px\">#{@perform}</td>\n</tr>"
    end
    html << "</table>"
  rescue Exception => error
    "<p>There was an error when loading <code>config/typus.yml</code>.</p>
    <h3>Error</h3>
    <pre>#{error}</pre>"
  end

  def typus_form(fields = @form_fields)
    html = error_messages_for :item, :header_tag => "h3"
    fields.each do |field|
      case field[0] # Field Name
      when 'uploaded_data'
        html << "<p><label>Upload File</label>"
      else
        html << "<p><label>#{field[0].titleize}</label>"
      end
      case field[1] # Field Type
      when "boolean"
        html << "#{check_box :item, field[0]} Checked if active"
      when "blob"
        html << "#{file_field :item, field[0], :style => 'border: 0px;'}"
      when "datetime"
        html << "#{datetime_select :item, field[0], { :minute_step => 5 }}"
      when "password"
        html << "#{password_field :item, field[0], :class => 'big'}"
      when "string", "integer", "float"
        html << "#{text_field :item, field[0], :class => 'big'}"
      when "text"
        html << "#{text_area :item, field[0], :rows => '10'}"
      when "tree"
        html << "<select id=\"item_#{field[0]}\" name=\"item[#{field[0]}]\">\n"
        html << "#{expand_tree_into_select_field(Category.top)}"
        html << "</select>\n"
      when "selector"
        values = eval field[0].upcase
        # html << "#{select :item, field[0], values.collect { |p| [ "#{p[0]} (#{p[1]})", p[1] ] }, :include_blank => true}"
        html << "<select id=\"item_#{field[0]}\" name=\"item[#{field[0]}]\">"
        html << "<option value=\"\">Select a #{field[0].capitalize}</option>"
        values.each do |value|
          html << "<option #{"selected" if @item.send(field[0]).to_s == value.last.to_s} value=\"#{value.last}\">#{value.first}</option>"
        end
        html << "</select>"
      when "preview"
        if @item.content_type == nil
          html << "No Preview Available"
        elsif @item.content_type.include? "image"
          # html << "<td>#{lightview_image_tag item.public_filename, :title => item.filename}</td>"
          html << "<a href=\"#{@item.public_filename}\" title=\"::\" rel=\"lightview\">#{image_tag (@item.public_filename(), {:style => "border: 1px solid #000;", :width => "250px" })}</a>"
        else
          html << "No Preview Available for <strong>#{@item.content_type}</strong>"
        end
      when "collection"
        related = field[0].split("_id").first.capitalize.constantize
        if (related.new.attributes.keys.include? 'name') || (related.new.methods.include? 'name')
          html << "#{collection_select :item, "#{field[0]}", related.find(:all), :id, :name, :include_blank => true}"
        else
          html << "#{select :item, "#{field[0]}", related.find(:all).collect { |p| ["#{related}##{p.id}", p.id] }, :include_blank => true}"
        end
      end
      html << "</p>"
    end
    return html
  rescue Exception => error
    "<p>There was an error when loading <code>config/typus.yml</code>.</p>
    <h3>Error</h3>
    <pre>#{error}</pre>"
  end

  # TODO: Don't show form if there are not more Items available.
  def typus_form_externals
    html = ""
    if @form_fields_externals
      @form_fields_externals.each do |field|
        model_to_relate = field.singularize.camelize.constantize
        html << "<h2 style=\"margin: 20px 0px 10px 0px;\">#{field.titleize} <small>#{link_to "Add new", :model => field, :action => 'new', :btm => params[:model], :bti => params[:id], :bta => params[:action]}</small></h2>"
        items_to_relate = (model_to_relate.find(:all) - @item.send(field))
        if items_to_relate.size > 0
          html << <<-HTML
            #{form_tag :action => "relate", :related => field, :id => params[:id]}
            <p>#{select "model_id_to_relate", :related_id, items_to_relate.map { |f| [f.name, f.id] }}
          &nbsp; #{submit_tag "Add"}
            </form></p>
          HTML
        end
        current_model = params[:model].singularize.camelize.constantize
        @items = current_model.find(params[:id]).send(field)
        html << typus_table(field) if @items.size > 0
      end
    end
    return html
  rescue Exception => error
    "<p>There was an error when loading <code>config/typus.yml</code>.</p>
    <h3>Error</h3>
    <pre>#{error}</pre>"
  end

  def process_query(q)
    if params[:search]
      query = "Search results on <strong>#{params[:model]}</strong> "
      query << "for <strong>\"#{params[:search]}\"</strong>"
    end
    return query
  end

  # Block of code
  def typus_block(name)
    render :partial => "typus/#{params[:model]}/#{name}.html.erb"
  rescue
    nil
  end

  def expand_tree_into_select_field(categories)
    returning(String.new) do |html|
      categories.each do |category|
        html << %{<option #{"selected" if @item.parent_id == category.id} value="#{ category.id }">#{ "-" * category.ancestors.size } #{category.name}</option>}
        html << expand_tree_into_select_field(category.children) if category.has_children?
      end
    end
  end

end