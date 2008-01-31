class TypusController < ApplicationController

  before_filter :authenticate, :except => [ :login, :logout ]
  before_filter :set_previous_action, :except => [ :dashboard, :login, :logout, :create ]
  before_filter :set_model, :except => [ :dashboard, :login, :logout ]
  before_filter :check_role, :except => [ :dashboard, :login, :logout ]
  before_filter :set_order, :only => [ :index ]
  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :status, :position ]
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit, :create, :update ]

  def dashboard
  end

  def index
    # select_fields = Typus::Configuration.config["#{@model.to_s.titleize}"]["fields"]["list"].split(", ") << "id"
    conditions = "1 = 1 "
    conditions << (request.env['QUERY_STRING']).build_conditions(@model) if request.env['QUERY_STRING']
    @items = @model.paginate :page => params[:page], 
                             :per_page => Typus::Configuration.options[:per_page], 
                             :order => "#{params[:order_by]} #{params[:sort_order]}", 
                             # :select => select_fields.join(", "),
                             :conditions => "#{conditions}"
  rescue
    flash[:notice] = "There was an error on the model."
    redirect_to :action => 'dashboard'
  end

  def new
    @item = @model.new
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      if session[:typus_previous]
        previous = session[:typus_previous]
        btm, bta, bti = previous[:btm], previous[:bta], previous[:bti]
        session[:typus_previous] = nil
        # Model to relate
        model_to_relate = btm.singularize.camelize.constantize
        @item.send(btm) << model_to_relate.find(bti)
        # And finally redirect to the previous action
        flash[:notice] = "Assigned #{@item.class} to #{btm} successfully."
        redirect_to :action => bta, :model => btm, :id => bti
      else
        flash[:notice] = "#{@model.to_s.capitalize} successfully created."
        redirect_to :action => 'edit', :id => @item
      end
    else
      render :action => 'new'
    end
  end

  def edit
    condition = ( @model.new.attributes.include? 'created_at' ) ? 'created_at' : 'id'
    current = ( condition == 'created_at' ) ? @item.created_at : @item.id
    @previous = @model.typus_find_previous(current, condition)
    @next = @model.typus_find_next(current, condition)
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = "#{@model.to_s.titleize} successfully updated."
      redirect_to :action => 'edit', :id => @item
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item.destroy
    flash[:notice] = "#{@model.to_s.titleize} successfully removed."
    redirect_to typus_index_url(params[:model])
  end

  # Toggle the status of an item.
  def status
    @item.toggle!('status')
    flash[:notice] = "#{@model.to_s.titleize.capitalize} status changed"
    redirect_to :action => 'index'
  end

  # Change item position
  def position
    case params[:go]
      when 'up':   @item.move_higher
      when 'down': @item.move_lower
    end
    flash[:notice] = "Position changed ..."
    redirect_to :action => 'index'
  end

  # Relate a model object to another.
  def relate
    model_to_relate = params[:related].singularize.capitalize.constantize
    @model.find(params[:id]).send(params[:related]) << model_to_relate.find(params[:model_id_to_relate][:related_id])
    flash[:notice] = "#{model_to_relate} added to #{@model.to_s.titleize}"
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Remove relationship between models.
  def unrelate
    model_to_unrelate = params[:unrelated].singularize.capitalize.constantize
    unrelate = model_to_unrelate.find(params[:unrelated_id])
    @model.find(params[:id]).send(params[:unrelated]).delete(unrelate)
    flash[:notice] = "#{model_to_unrelate} removed from #{@model.to_s.titleize}"
    redirect_to :action => 'edit', :id => params[:id]
  end

  # Basic session creation.
  def login
    if request.post?
      # Login using Typus::Configuration.options
      if Typus::Configuration.options[:username] && Typus::Configuration.options[:password]
        username = Typus::Configuration.options[:username]
        password = Typus::Configuration.options[:password]
        if params[:user][:name] == username && params[:user][:password] == password
          session[:typus] = true
          redirect_to typus_dashboard_url
        else
          flash[:error] = "Username/Password Incorrect"
          redirect_to typus_login_url
        end
      # Login using TypusUser
      else
        # TypusUser.count.size > 0
        @user = TypusUser.authenticate(params[:user])
        if @user
          session[:typus] = @user
          redirect_to typus_dashboard_url
        else
          flash[:error] = "Username/Password Incorrect"
          redirect_to typus_login_url
        end
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

private

  # Set the current model.
  def set_model
    @model = params[:model].singularize.camelize.constantize
  end

  # Set default order on the listings.
  def set_order
    order = @model.typus_defaults_for('order_by')
    if order
      params[:order_by] = params[:order_by] || order[0]
    else
      params[:order_by] = params[:order_by] || 'id'
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

  # Find
  def find_model
    @item = @model.find(params[:id])
  end

  # Model fields
  def fields
    @fields = @model.typus_fields_for('list')
  end

  # Model +form_fields+ & +form_externals+
  def form_fields
    @form_fields = @model.typus_fields_for('form')
    @form_fields_externals = @model.typus_defaults_for('relationships')
  end

private

  # Authenticate
  def authenticate
    if session[:typus]
      if session[:typus].class == TypusUser
        @typus_user = TypusUser.find(session[:typus].id)
      end
    else
      redirect_to typus_login_url
    end
  end

  # if TypusUser.count.size > 0
  def check_role
    unless Typus::Configuration.options[:username] && Typus::Configuration.options[:password]
      if !@typus_user.models.include? @model
        flash[:notice] = "Don't have access to #{params[:model].capitalize}"
        redirect_to :action => "dashboard"
      end
    end
  end

end