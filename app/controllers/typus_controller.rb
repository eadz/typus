class TypusController < ApplicationController

  DB = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV]

  before_filter :authenticate, :except => [ :login, :logout ]
  before_filter :set_model, :except => [ :dashboard, :login, :logout ]
  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :status ]
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit, :update ]

  def dashboard
  end

  def index
    set_order
    @conditions = ""
    # Get all the params and process them ...
    if request.env['QUERY_STRING']
      @query = request.env['QUERY_STRING']
      @query.split("&").each do |query|
        @the_param = query.split("=")[0].split("_id")[0]
        @the_query = query.split("=")[1]
        
        # If it's a query
        if @the_param == "query"
          @search = Array.new
          @model.search_fields.each { |search| @search << "LOWER(#{search}) LIKE '%#{@the_query}%'" }
          @conditions += "(#{@search.join(" OR ")}) AND "
        end
        
        @model.filters.each do |f|
          filter_type = f[1] if f[0].to_s == @the_param.to_s
          # And the common defined types of data
          case filter_type
          when "boolean"
            if %w(sqlite3 sqlite).include? DB['adapter']
              @conditions += "#{f[0]} = '#{@the_query[0..0]}' AND "
            else
              @status = (@the_query == 'true') ? 1 : 0
              @conditions += "#{f[0]} = '#{@status}' AND "
            end
          when "datetime"
            case @the_query
            when "today":         @start_date, @end_date = Time.today, Time.today.tomorrow
            when "past_7_days":   @start_date, @end_date = Time.today.monday, Time.today.monday.next_week
            when "this_month":    @start_date, @end_date = Time.today.last_month, Time.today.tomorrow
            when "this_year":     @start_date, @end_date = Time.today.last_year, Time.today.tomorrow
            end
            @start_date = @start_date.strftime("%Y-%m-%d %H:%M:%S")
            @end_date = @end_date.strftime("%Y-%m-%d %H:%M:%S")
            @conditions += "created_at > '#{@start_date}' AND created_at < '#{@end_date}' AND "
          when "collection"
            @conditions += "#{f[0]}_id = #{@the_query} AND "
          end
        end
      end
    end
    @conditions += "1 = 1"
    @order = params[:order_by]
    @sort_order = params[:sort_order]
    @items = @model.paginate :page => params[:page], :per_page => Typus::Configuration.options[:per_page], :order => "#{@order} #{@sort_order}", :conditions => "#{@conditions}"
  end

  def new
    @item = @model.new
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      flash[:notice] = "#{@model.to_s.capitalize} successfully created."
      redirect_to :action => 'index' # :action => "edit", :id => @item.id
    else
      @form_fields = @model.form_fields
      render :action => "new"
    end
  end

  def edit
    @condition = ( @model.new.attributes.include? "created_at" ) ? "created_at" : "id"
    @current_item = ( @condition == "created_at" ) ? @item.created_at : @item.id
    @previous = @model.find(:first, :order => "#{@condition} DESC", :conditions => ["#{@condition} < ?", @current_item])
    @next = @model.find(:first, :order => "#{@condition} ASC", :conditions => ["#{@condition} > ?", @current_item])
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = "#{@model.to_s.capitalize} successfully updated."
      redirect_to :action => "edit", :id => @item.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @item.destroy
    flash[:notice] = "#{@model.to_s.capitalize} has ben successfully removed."
    redirect_to :action => "index", :model => params[:model], :controller => "typus", :id => nil
  end

  def status
    @item.toggle!("status")
    flash[:notice] = "#{@model.to_s.capitalize} status changed"
    redirect_to :action => "index"
  end

  def relate
    model_to_relate = eval params[:related].singularize.capitalize
    @model.find(params[:id]).send(params[:related]) << model_to_relate.find(params[:model_id_to_relate][:related_id])
    flash[:notice] = "#{model_to_relate} added to #{@model}"
    redirect_to :action => "edit", :id => params[:id]
  end

  def unrelate
    model_to_unrelate = eval params[:unrelated].singularize.capitalize
    unrelate = model_to_unrelate.find(params[:unrelated_id])
    @model.find(params[:id]).send(params[:unrelated]).delete(unrelate)
    flash[:notice] = "#{model_to_unrelate} removed from #{@model}"
    redirect_to :action => "edit", :id => params[:id]
  end

  def login
    if request.post?
      if params[:user][:name] == Typus::Configuration.username && params[:user][:password] == Typus::Configuration.password
        session[:typus] = true
        redirect_to :action => "dashboard"
      else
        flash[:error] = "Username/Password Incorrect"
        redirect_to :action => "login"
      end
    else
      render :layout => "typus_login"
    end
  end

  def logout
    reset_session
    redirect_to :action => "login"
  end

private

  def set_model
    @model = eval params[:model].singularize.capitalize
  end

  def set_order
    @model = eval params[:model].singularize.capitalize
    @order = @model.default_order
    params[:order_by] = params[:order_by] || @order[0][0] || "id"
    params[:sort_order] = params[:sort_order] || @order[0][1] || "asc"
  end

  def find_model
    @item = @model.find(params[:id])
  end

  def fields
    @fields = @model.list_fields
  end

  def form_fields
    @form_fields = @model.form_fields
    @form_fields_externals = @model.form_fields_externals
  end

  private

  def authenticate
    redirect_to :action => "login" unless session[:typus]
    # authenticate_or_request_with_http_basic(realm = TYPUS['app_name']) do |user_name, password|
      # user_name == TYPUS['app_username'] && password == TYPUS['app_password']
      ## TYPUS['admins'].each { |user| user_name == user[0] && password == user[1] }
    #end
  end

end