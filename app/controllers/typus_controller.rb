class TypusController < ApplicationController

  filter_parameter_logging :password

  include Authentication

  before_filter :require_login, :except => [ :login, :logout, :email_password ]
  before_filter :current_user, :except => [ :login, :logout, :email_password ]

  before_filter :set_previous_action, :except => [ :dashboard, :login, :logout, :create, :email_password ]
  before_filter :set_model, :except => [ :dashboard, :login, :logout, :email_password ]

  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :toggle, :position ]

  before_filter :check_permissions, :only => [ :new, :create, :edit, :update, :destroy, :toggle ]

  before_filter :set_order, :only => [ :index ]
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit, :create, :update ]

  ##
  # Application Dashboard
  def dashboard
  end

  ##
  # Index
  def index
    conditions = "1 = 1"
    conditions << " " + (request.env['QUERY_STRING']).build_conditions(@model) if request.env['QUERY_STRING']
    items_count = @model.count(:conditions => conditions)
    items_per_page = Typus::Configuration.options[:per_page].to_i
    @pager = ::Paginator.new(items_count, items_per_page) do |offset, per_page|
      # ActiveRecord
      @model.find(:all, 
                  :conditions => "#{conditions}", 
                  :order => @order, 
                  :limit => per_page, 
                  :offset => offset)
      # DataMapper
      # @model.all(:limit => per_page, :offset => offset)
    end
    @items = @pager.page(params[:page])

    ##
    # Render custom index page otherwise render Typus default

    if File.exists?("#{RAILS_ROOT}/app/views/typus/#{params[:model]}/index.html.erb")
      render :template => "typus/#{params[:model]}/index"
    else
      render :template => "typus/index"
    end

  end

  def new
    item_params = params.dup
    item_params.delete_if { |key, value| key == 'action' }
    item_params.delete_if { |key, value| key == 'controller' }
    item_params.delete_if { |key, value| key == 'model' }
    item_params.delete_if { |key, value| key == 'btm' }
    item_params.delete_if { |key, value| key == 'bta' }
    item_params.delete_if { |key, value| key == 'bti' }
    @item = @model.new(item_params.symbolize_keys)
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      if session[:typus_previous]

        ##
        # Recover the session
        previous = session[:typus_previous]
        btm, bta, bti = previous[:btm], previous[:bta], previous[:bti]
        session[:typus_previous] = nil

        ##
        # Model to relate
        model_to_relate = btm.singularize.camelize.constantize
        @item.send(btm) << model_to_relate.find(bti)

        ##
        # And finally redirect to the previous action
        flash[:success] = "#{@item.class} assigned to #{btm.singularize} successfully."
        redirect_to :action => bta, :model => btm, :id => bti

      else
        flash[:success] = "#{@model.to_s.titleize} successfully created."
        redirect_to :action => 'edit', :id => @item.id
      end

    else
      render :action => 'new'
    end
  end

  def edit

    condition = ( @model.new.attributes.include? 'created_at' ) ? 'created_at' : @model.primary_key
    current = ( condition == 'created_at' ) ? @item.created_at : @item.id

    ##
    # Link to previous and next

    @previous = @model.typus_find_previous(current, condition)
    @next = @model.typus_find_next(current, condition)

    ##
    # Render custom index page otherwise render Typus default

    if File.exists?("#{RAILS_ROOT}/app/views/typus/#{params[:model]}/edit.html.erb")
      render :template => "typus/#{params[:model]}/edit"
    else
      render :template => "typus/edit"
    end

  end

  def update
    if @item.update_attributes(params[:item])
      flash[:success] = "#{@model.to_s.titleize} successfully updated."
      redirect_to :action => 'edit', :id => @item.id
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item.destroy
    flash[:success] = "#{@model.to_s.titleize} successfully removed."
    redirect_to :params => params.merge(:action => 'index', :id => nil)
  end

  # Toggle the status of an item.
  def toggle
    @item.toggle!(params[:field])
    flash[:success] = "#{@model.to_s.titleize.capitalize} #{params[:field]} changed."
    redirect_to :action => 'index', :params => params.merge(:field => nil, :action => 'index', :id => nil)
  end

  # Change item position
  def position
    case params[:go]
      when 'top':         @item.move_to_top
      when 'up':          @item.move_higher
      when 'down':        @item.move_lower
      when 'bottom':      @item.move_to_bottom
    end
    flash[:success] = "Position changed ..."
    redirect_to :back
  end

  # Relate a model object to another.
  def relate
    model_to_relate = params[:related].singularize.camelize.constantize
    @model.find(params[:id]).send(params[:related]) << model_to_relate.find(params[:model_id_to_relate][:related_id])
    flash[:success] = "#{model_to_relate.to_s.titleize} added to #{@model.to_s.titleize}."
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Remove relationship between models.
  def unrelate
    model_to_unrelate = params[:unrelated].singularize.camelize.constantize
    unrelate = model_to_unrelate.find(params[:unrelated_id])
    @model.find(params[:id]).send(params[:unrelated]).delete(unrelate)
    flash[:success] = "#{model_to_unrelate.to_s.titleize} removed from #{@model.to_s.titleize}."
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Basic session creation.
  def login
    if request.post?
      @user = TypusUser.authenticate(params[:user][:email], params[:user][:password])
      if @user
        session[:typus] = @user.id
        redirect_to typus_dashboard_url
      else
        flash[:error] = "The Email and/or Password you entered is invalid."
        redirect_to typus_login_url
      end
    else
      render :layout => 'typus_login'
    end
  end

  # End typus session and redirect to +typus_login+.
  def logout
    session[:typus] = nil
    redirect_to typus_login_url
  end

  def email_password
    if request.post?
      typus_user = TypusUser.find_by_email(params[:user][:email])
      if typus_user
        password = generate_password
        host = request.env['HTTP_HOST']
        typus_user.reset_password(password, host)
        flash[:success] = "New password sent to #{params[:user][:email]}"
        redirect_to typus_login_url
      else
        flash[:error] = "Email doesn't exist on the system."
        redirect_to typus_email_password_url
      end
    else
      render :layout => 'typus_login'
    end
  end

private

  # Set the current model.
  def set_model
    @model = params[:model].modelize
  rescue NameError
      flash[:notice] = "No such model"
      redirect_to :action => 'dashboard'
  end

  # Set default order on the listings.
  def set_order
    unless params[:order_by]
      @order = @model.typus_order_by
    else
      @order = "#{params[:order_by]} #{params[:sort_order]}"
    end
  end

  # btm: Before this model
  # bta: Before this action
  # bti: Before this id
  def set_previous_action
    session[:typus_previous] = nil
    if params[:bta] && params[:btm]
      previous = Hash.new
      previous[:btm], previous[:bta], previous[:bti] = params[:btm], params[:bta], params[:bti]
      session[:typus_previous] = previous
    end
  end

  ##
  # Find
  def find_model
    @item = @model.find(params[:id])
  end

  ##
  # Model +fields+
  def fields
    @fields = @model.typus_fields_for('list')
  end

  ##
  # Model +form_fields+ and +form_fields_externals+
  def form_fields
    @item_fields = @model.typus_fields_for('form')
    @item_has_many = @model.typus_relationships_for('has_many')
    @item_has_and_belongs_to_many = @model.typus_relationships_for('has_and_belongs_to_many')
  end

private

  ##
  # Before filter to check if has permission to edit/add the post.
  def check_permissions

    case params[:action]
    when 'new'
      @item = @model.new
      action = "add" unless can_add? @item
    when 'edit'
      action = "edit" unless can_edit? @item
    when 'destroy'
      action = "destroy" unless can_destroy? @item
    when 'toggle'
      action = "toogle" unless can_toggle? @item
    end

    if action
      flash[:notice] = "You can't #{action} a #{@item.class.to_s.titleize}."
      redirect_to :controller => 'typus', :action => 'index', :model => params[:model]
    end

  end

end
