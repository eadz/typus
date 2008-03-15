require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/controllers/typus_controller'
require File.dirname(__FILE__) + '/../../app/models/typus_user'

class TypusControllerTest < ActionController::TestCase

  fixtures :posts, :typus_users

  def test_should_redirect_to_login
    get :index
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_login_and_redirect_to_dashboard
    post :login, { :user => { :email => 'admin@typus.org', :password => '12345678' }}
    assert_equal @request.session[:typus], 1
    assert_response :redirect
    assert_redirected_to typus_dashboard_url
  end

  def test_should_not_login_disable_user
    post :login, { :user => { :email => 'disabled_user@typus.org', :password => '12345678' }}
    assert_equal @request.session[:typus], nil
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_render_index
    post :login, { :user => { :email => 'admin@typus.org', :password => '12345678' }}
    assert_equal @request.session[:typus], 1
    get :index, { :model => 'posts' }
    assert_response :success
    assert_template 'index'
  end

  def test_should_not_render_index_for_undefined_model
    assert true
    # @request.session[:typus] = 1
    # get :index, { :model => 'unexisting' }
    # assert_response :redirect
    # assert_redirected_to :action => 'dashboard'
  end

  def test_should_render_new
    @request.session[:typus] = 1
    get :new, { :model => 'posts' }
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_item
    @request.session[:typus] = true
    items = Post.count
    post :create, { :model => 'posts', :item => { :title => "This is another title", :body => "This is the body."}}
    assert_response :redirect
    assert_redirected_to :action => 'edit'
    assert_equal items, 2
  end

  def test_should_render_edit
    @request.session[:typus] = 1
    get :edit, { :model => 'posts', :id => 1 }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_update_item
    @request.session[:typus] = 1
    post :update, { :model => 'posts', :id => 1, :title => "Updated" }
    assert_response :redirect
    assert_redirected_to :action => 'edit'
  end

  def test_should_logout
    @request.session[:typus] = 1
    get :logout
    assert_equal @request.session[:typus], nil
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_perform_a_search
    @request.session[:typus] = 1
    get :index, { :model => 'posts', :search => 'neinonon' }
    assert_response :success
    assert_template 'index'
  end

  def test_should_allow_admin_add_users
    admin = TypusUser.find(1)
    @request.session[:typus] = admin.id
    get :new, { :model => 'typus_users' }
    assert_response :success
  end

  def test_should_not_allow_a_user_add_users
    user = TypusUser.find(2)
    @request.session[:typus] = user.id
    get :new, { :model => 'typus_users' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  # FIXME: probably duplicated
  def test_should_allow_admin_to_edit_himself
    admin = TypusUser.find(1)
    @request.session[:typus] = admin.id
    get :edit, { :model => 'typus_users', :id => admin.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_allow_admin_to_edit_other_users
    admin = TypusUser.find(1)
    user = TypusUser.find(2)
    @request.session[:typus] = admin.id
    get :edit, { :model => 'typus_users', :id => user.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_allow_user_to_edit_himself
    user = TypusUser.find(2)
    @request.session[:typus] = user.id
    get :edit, { :model => 'typus_users', :id => user.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_not_allow_uset_to_edit_other_users
    admin = TypusUser.find(1)
    user = TypusUser.find(2)
    @request.session[:typus] = user.id
    get :edit, { :model => 'typus_users', :id => admin.id }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_run_defined_action
    admin = TypusUser.find(1)
    @request.session[:typus] = admin.id
    # FIXME
    # get :run, { :model => 'posts', :task => 'cleanup' }
    # assert_response :redirect
    # assert_redirected_to :action => 'index'
  end

=begin

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

=end

end