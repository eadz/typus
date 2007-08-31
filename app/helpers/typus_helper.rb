module TypusHelper

  def head
    render :partial => "head"
  end

  def header
    render :partial => "header"
  end

  def modules
    @config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    @modules = []
    @config.each do |i|
      @modules << i if i[1]["default"]
    end
    @list = "<ul>"
    @modules.each do |i|
      @list += "<li><a href=\"/admin/#{i[0].downcase.pluralize}\">#{i[1]["module"].capitalize}</a></li>"
    end
    @list += "</ul>"
    return @list
  end

  def sidebar
    @config = YAML.load_file("#{RAILS_ROOT}/config/typus.yml")
    @current = params[:controller].split("/")[1]
    @config.each do |i|
      @model = i if i[1]["module"] == @current
    end
    @module = @config["#{@model}"]["module"]
    @tonch = ""
    @config.each do |m|
      if m[1]["module"] == @module
        @tonch += "<h2><a href=\"/admin/#{m[0].downcase.pluralize}\">#{m[0].pluralize.capitalize}</a> <small><a href=\"/admin/#{m[0].downcase.pluralize}/new\">New</a></small></h2>"
        @tonch += "<p>#{m[1]["copy"]}</p>" if m[1]["copy"]
        if m[1]["filters"]
          @tonch += "<ul>"
          m[1]["filters"].split(" ").each do |f|
            if f == "status"
              @tonch += "<li><a href=\"/admin/#{m[0].downcase.pluralize}?status=true\">Active</a></li>"
              @tonch += "<li><a href=\"/admin/#{m[0].downcase.pluralize}?status=false\">Inactive</a></li>"
            else
              
            end
          end
          @tonch += "</ul>"
        end
      end
    end
    return @tonch
  rescue
    return "FixMe"
  end

  def feedback
    if flash[:notice]
      "<div id=\"notice\">#{flash[:notice]}</div>"
    elsif flash[:error]
      "<div id=\"notice-error\">#{flash[:error]}</div>"
    end
  end

  def footer
    render :partial => "footer"
  end

  def fmt_date(date)
    date.strftime("%d.%m.%Y")
  end

end