class TypusController < ApplicationController

  before_filter :set_workspace
  before_filter :authenticate
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit ]
  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :status ]

  self.template_root = "#{RAILS_ROOT}/vendor/plugins/typus/app/views"
  layout 'typus'

  def index
    if params[:status]
      @status = params[:status] == "true" ? true : false
      @item_pages, @items = paginate @model, :conditions => ["status = ?", @status], :order => "id DESC", :per_page => TYPUS[:per_page]
    elsif params[:search]
      @search = "%#{params[:search].downcase}%"
      @item_pages, @items = paginate @model, :conditions => ["LOWER(title) LIKE ?", @search], :order => "id DESC", :per_page => TYPUS[:per_page]
    elsif params[:order_by]
      @order = params[:order_by]
      @sort_order = params[:sort_order]
      @item_pages, @items = paginate @model, :order => "#{@order} #{@sort_order}", :per_page => TYPUS[:per_page]
    else
      @item_pages, @items = paginate @model, :order => "id DESC", :per_page => TYPUS[:per_page]
    end
  end

  def new
    @item = @model.new
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      flash[:notice] = "#{@model.to_s.capitalize} successfully created."
      redirect_to :action => "edit", :id => @item.id # , :model => params[:model]
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

  def search
    unless params[:search] == ""
      @items = @model.find(:all, :order => 'created_at DESC', :conditions => [ 'LOWER(body) LIKE ? OR LOWER(name) LIKE ?', '%' + params[:search] + '%', '%' + params[:search] + '%' ])
    else
      flash[:error] = "Please, insert a query string."
    end
  end

  def status
    @item.toggle!("status")
    flash[:notice] = "#{@model.to_s.capitalize} status changed"
    redirect_to :action => "index"
  end

private

  def find_model
    @item = @model.find(params[:id])
  end

  def fields
    @fields = @model.list_fields
  end

  def form_fields
    @form_fields = @model.form_fields
  end

  def set_workspace
    @fields = %w( id )
    params[:order_by] = params[:order_by] || @fields[0]
    params[:sort_order] = params[:sort_order] || "asc"
    @model = ( params[:model] ) ? (eval params[:model].singularize.capitalize) : User
  end

  def authenticate
    redirect_to login_url unless session[:typus]
  end

end