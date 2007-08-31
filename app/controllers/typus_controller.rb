class TypusController < ApplicationController

  self.template_root = "#{RAILS_ROOT}/vendor/plugins/typus/app/views"
  layout 'typus'

  before_filter :set_workspace
  before_filter :authenticate

  def index
    @fields = @model.list_fields
    if params[:status]
      @items = @model.find(:all, :conditions => ["status = ?", params[:status]], :limit => "20")
    elsif params[:order_by]
      @order = params[:order_by]
      @sort_order = params[:sort_order]
      @items = @model.find(:all, :order => "#{@order} #{@sort_order}", :limit => "30")
    else
      @items = @model.find(:all, :order => "id DESC", :limit => "40")
    end
  end

  def new
    @form_fields = @model.form_fields
    @item = @model.new
  end

  def create
    @item = @model.new(params[:item])
    if @item.save
      flash[:notice] = "#{@model.to_s.capitalize} successfully created."
      redirect_to :action => "edit", :id => @item
    else
      @form_fields = @model.form_fields
      render :action => "new"
    end
  end

  def edit
    @form_fields = @model.form_fields
    @item = @model.find(params[:id])
    # @condition = @model.form_fields.include? "created_at" ? "created_at" : "id"
    # @previous = @model.find(:first, :order => "#{@condition} DESC", :conditions => ["#{@condition} < ?", @item])
    # @next = @model.find(:first, :order => "#{@condition} ASC", :conditions => ["#{@condition} > ?", @item])
  end

  def update
    @item = @model.find(params[:id])
    if @item.update_attributes(params[:item])
      flash[:notice] = "#{@model.to_s.capitalize} successfully updated."
      redirect_to :action => "edit", :id => @item
    else
      render :action => "edit"
    end
  end

  def destroy
    @model.find(params[:id]).destroy
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
    @item = @model.find(params[:id])
    @item.toggle!("status")
    flash[:notice] = "#{@model.to_s.capitalize} status changed"
    redirect_to :action => "index"
  end

private

  def set_workspace
    @fields = %w( id )
    params[:order_by] = params[:order_by] || @fields[0]
    params[:sort_order] = params[:sort_order] || "asc"
    if params[:model]
      @model = params[:model].singularize.capitalize.inject(Object){ |klass, part| klass.const_get(part) }
    else
      @model = User
    end
  end

  def authenticate
    redirect_to login_url unless session[:typus]
  end

end