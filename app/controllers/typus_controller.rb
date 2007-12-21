class TypusController < ApplicationController

  DB = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV]

  before_filter :authenticate, :except => [ :login, :logout ]
  before_filter :set_model, :except => [ :dashboard, :login, :logout ]
  before_filter :set_order, :only => [ :index ]
  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :status ]
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit, :create, :update ]

  def dashboard
  end

  def index
    @conditions = ""
    # Get all the params and process them ...
    if request.env['QUERY_STRING']
      @query = request.env['QUERY_STRING']
      @query.split("&").each do |query|
        @the_param = query.split("=")[0].split("_id").first
        @the_query = query.split("=").last
        
        # If it's a query
        if @the_param == "query"
          @search = Array.new
          @model.search_fields.each { |s| @search << "LOWER(#{s}) LIKE '%#{@the_query}%'" }
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
            when "today"
              @start_date, @end_date = Time.today, Time.today.tomorrow
            when "past_7_days"
              @start_date, @end_date = Time.today.monday, Time.today.monday.next_week
            when "this_month"
              @start_date, @end_date = Time.today.last_month, Time.today.tomorrow
            when "this_year"
              @start_date, @end_date = Time.today.last_year, Time.today.tomorrow
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
    @items = @model.paginate :page => params[:page], 
                             :per_page => Typus::Configuration.options[:per_page], 
                             :order => "#{params[:order_by]} #{params[:sort_order]}", 
                             :conditions => "#{@conditions}"
  rescue
    redirect_to :action => 'index'
  end

  def new
    @item = @model.new
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      flash[:notice] = "#{@model.to_s.capitalize} successfully created."
      redirect_to typus_index_url(params[:model])
    else
      render :action => 'new'
    end
  end

  def edit
    condition = ( @model.new.attributes.include? 'created_at' ) ? 'created_at' : 'id'
    current = ( condition == 'created_at' ) ? @item.created_at : @item.id
    @previous = @model.find(:first, 
                            :order => "#{condition} DESC", 
                            :conditions => ["#{condition} < ?", current])
    @next = @model.find(:first, 
                        :order => "#{condition} ASC", 
                        :conditions => ["#{condition} > ?", current])
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = "#{@model.to_s.capitalize} successfully updated."
      redirect_to :action => 'edit', :id => @item
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item.destroy
    flash[:notice] = "#{@model.to_s.capitalize} has been successfully removed."
    redirect_to typus_index_url(params[:model])
  end

  # Toggle the status of an item.
  def status
    @item.toggle!('status')
    flash[:notice] = "#{@model.to_s.capitalize} status changed"
    redirect_to :action => 'index'
  end

  # Relate a model object to another.
  def relate
    model_to_relate = params[:related].singularize.capitalize.constantize
    @model.find(params[:id]).send(params[:related]) << model_to_relate.find(params[:model_id_to_relate][:related_id])
    flash[:notice] = "#{model_to_relate} added to #{@model}"
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Remove relationship between models.
  def unrelate
    model_to_unrelate = params[:unrelated].singularize.capitalize.constantize
    unrelate = model_to_unrelate.find(params[:unrelated_id])
    @model.find(params[:id]).send(params[:unrelated]).delete(unrelate)
    flash[:notice] = "#{model_to_unrelate} removed from #{@model}"
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Runs model "extra actions". This is defined in +typus.yml+ as
  # +actions+.
  #
  # Post:
  #   actions: cleanup:index notify_users:edit
  #
  def run
    if params[:id]
      if @model.actions.include? [params[:task], 'edit']
        flash[:notice] = "#{params[:task].humanize} performed."
        @model.find(params[:id]).send(params[:task])
        redirect_to :action => 'edit', :id => params[:id]
      end
    else
      if @model.actions.include? [params[:task], 'index']
        flash[:notice] = "#{params[:task].humanize} performed."
        @model.send(params[:task])
        redirect_to :action => 'index'
      end
    end
  rescue
    redirect_to :action => 'index'
  end

  # Basic session creation.
  def login
    if request.post?
      username = Typus::Configuration.options[:username]
      password = Typus::Configuration.options[:password]
      if params[:user][:name] == username && params[:user][:password] == password
        session[:typus] = true
        redirect_to typus_dashboard_url
      else
        flash[:error] = "Username/Password Incorrect"
        redirect_to typus_login_url
      end
    else
      render :layout => 'typus_login'
    end
  end

  # End the session and redirect to login screen.
  def logout
    session[:typus] = nil
    redirect_to typus_login_url
  end

private

  # Sets the current model.
  def set_model
    @model = params[:model].singularize.capitalize.constantize
  end

  # Set the default order of the model listings.
  def set_order
    @order = @model.default_order
    params[:order_by] = params[:order_by] || @order[0].first || 'id'
    params[:sort_order] = params[:sort_order] || @order[0].last || 'asc'
  end

  # Find 
  def find_model
    @item = @model.find(params[:id])
  end

  # Model fields
  def fields
    @fields = @model.list_fields
  end

  # Model form fields and externals
  def form_fields
    @form_fields = @model.form_fields
    @form_fields_externals = @model.form_fields_externals
  end

private

  # Authenticate user before doing anything.
  def authenticate
    redirect_to typus_login_url unless session[:typus]
  end

end
