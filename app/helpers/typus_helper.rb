module TypusHelper

  TYPUS = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")

  def head
    @block = "<title>#{TYPUS["Typus"]["app_name"]} &rsaquo; #{page_title}</title>\n"
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
    @block = "<h1><a href=\"/admin\">#{TYPUS["Typus"]["app_name"]}</a> <small><a href=\"/admin/logout\">Logout</a></small></h1>\n"
    @block += "<h2>#{TYPUS["Typus"]["app_description"]}</h2>"
    return @block
  end

  def modules
    @modules = []
    TYPUS["Models"].each { |i| @modules << i if i[1]["default"] }
    @block = "<ul>\n"
    @modules.each { |i| @block += "<li><a href=\"/admin/#{i[0].downcase.pluralize}\">#{i[1]["module"].capitalize}</a></li>\n" }
    @block += "</ul>"
    return @block
  rescue
    return "FixMe: <strong>typus.yml</strong>"
  end

  def sidebar
    @current = params[:model] # .split("/")[1]
    TYPUS["Models"].each { |i| @model = i if i[1]["module"] == @current }
    @module = TYPUS["Models"]["#{@model}"]["module"]
    @block = ""
    TYPUS["Models"].each do |m|
      if m[1]["module"] == @module
        @block += "<h2><a href=\"/admin/#{m[0].downcase.pluralize}\">#{m[0].pluralize.capitalize}</a></h2>\n"
        @block += "<p>#{m[1]["copy"]}</p>\n" if m[1]["copy"]
        if m[0].downcase.pluralize == @current
          if m[1]["filters"]
            m[1]["filters"].split(" ").each do |f|
              if %w( status verified blocked).include? f
                @block += "<h3>Filter by #{f.capitalize}</h3>\n"
                @block += "<ul>\n"
                @block += "<li><a href=\"/admin/#{m[0].downcase.pluralize}?filter_by=#{f}&filter_id=true\">Active</a></li>\n"
                @block += "<li><a href=\"/admin/#{m[0].downcase.pluralize}?filter_by=#{f}&filter_id=false\">Inactive</a></li>\n"
                @block += "</ul>\n"
              end
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
    @block = "<p><a href=\"http://intraducibles.net/work/typus\">Typus #{TYPUS["Typus"]["version"]}</a></p>"
    return @block
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

end