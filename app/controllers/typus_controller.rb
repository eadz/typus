class TypusController < ApplicationController

  before_filter :authenticate
  before_filter :set_model
  before_filter :find_model, :only => [ :show, :edit, :update, :destroy, :status ]
  before_filter :fields, :only => [ :index ]
  before_filter :form_fields, :only => [ :new, :edit ]

  self.template_root = "#{RAILS_ROOT}/vendor/plugins/typus/app/views"
  layout 'typus'

  def index
    params[:order_by] = params[:order_by] || "id"
    params[:sort_order] = params[:sort_order] || "asc"
    if params[:status]
      @status = params[:status] == "true" ? true : false
      @item_pages, @items = paginate @model, :conditions => ["status = ?", @status], :order => "id DESC", :per_page => TYPUS[:per_page]
    elsif params[:search]
      @search = []
      @model.search_fields.each do |search|
        @search << "LOWER(#{search}) LIKE '%#{params[:search]}%'"
      end
      @item_pages, @items = paginate @model, :conditions => "#{@search.join(" OR ")}"
    elsif params[:order_by]
      @order = params[:order_by]
      @sort_order = params[:sort_order]
      @item_pages, @items = paginate @model, :order => "#{@order} #{@sort_order}", :per_page => TYPUS[:per_page]
    else
      @order = ""
      params[:order_by] = @model.default_order[0][0]
      params[:sort_order] = @model.default_order[0][1]
      @model.default_order.each do |order|
        @order += "#{order[0]} #{order[1].upcase }"
      end
      @item_pages, @items = paginate @model, :order => "#{@order}", :per_page => TYPUS[:per_page]
    end
  end

  def new
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
    @condition = ( @model.new.attributes.include? "created_at" ) ? "created_at" : "id"
    @current_item = ( @condition == "created_at" ) ? @item.created_at : @item.id
    @previous = @model.find(:first, :order => "#{@condition} DESC", :conditions => ["#{@condition} < ?", @current_item])
    @next = @model.find(:first, :order => "#{@condition} ASC", :conditions => ["#{@condition} > ?", @current_item])
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = "#{@model.to_s.capitalize} successfully updated."
      redirect_to :action => "edit", :id => @item
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

private

  def set_model
    @model = ( params[:model] ) ? (eval params[:model].singularize.capitalize) : User
  end

  def find_model
    @item = @model.find(params[:id])
  end

  def fields
    @fields = @model.list_fields
  end

  def form_fields
    @form_fields = @model.form_fields
  end

  def authenticate
    redirect_to login_url unless session[:typus]
  end

end