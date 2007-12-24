
require File.dirname(__FILE__) + '/../test_helper'

class TypusControllerTest < ActionController::TestCase

  fixtures :posts

  def test_should_redirect_to_login
    get :index
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_login_and_redirect_to_dashboard
    post :login, { :user => { :name => 'admin', :password => 'typus' }}
    assert_equal @request.session[:typus], true
    assert_response :redirect
    assert_redirected_to typus_dashboard_url
  end

  def test_should_login_and_render_dashboard
    @request.session[:typus] = true
    get :dashboard
    assert_response :success
    assert_template 'dashboard'
  end

  def test_should_render_index
    @request.session[:typus] = true
    get :index, { :model => 'posts' }
    assert_response :success
    assert_template 'index'
  end

  def test_should_not_render_index_for_undefined_model
    @request.session[:typus] = true
    get :index, { :model => 'unexisting' }
    assert_response :redirect
    assert_redirected_to :action => 'dashboard'
  end

  def test_should_render_new
    @request.session[:typus] = true
    get :new, { :model => 'posts' }
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_item
    @request.session[:typus] = true
    items = Post.count
    post :create, { :model => 'posts', :item => { :title => "This is another title", :body => "This is the body."}}
    assert_response :redirect
    assert_equal items, 2
  end

  def test_should_render_edit
    @request.session[:typus] = true
    get :edit, { :model => 'posts', :id => 1 }
    assert_response :success
  end

  def test_should_update_item
    @request.session[:typus] = true
    post :update, { :model => 'posts', :id => 1, :title => "Updated" }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_run_defined_action
    @request.session[:typus] = true
    get :run, { :model => 'posts', :task => 'cleanup' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_not_run_undefined_action
    @request.session[:typus] = true
    get :run, { :model => 'posts', :task => 'undefined_task' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_run_defined_action_on_item
    @request.session[:typus] = true
    get :run, { :model => 'posts',  :id => 1, :task => 'send_as_newsletter' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_not_run_undefined_action_on_item
    @request.session[:typus] = true
    get :run, { :model => 'posts',  :id => 1, :task => 'send_as_email' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_logout
    @request.session[:typus] = true
    get :logout
    assert_equal @request.session[:typus], nil
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_perform_a_search
    @request.session[:typus] = true
    get :index, { :model => 'posts', :search => 'neinonon' }
    assert_response :success
    assert_template 'index'
  end

end