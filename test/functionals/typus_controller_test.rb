require File.dirname(__FILE__) + '/../test_helper'

class TypusControllerTest < ActionController::TestCase

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
    @request.session[:typus] = 1
    get :index, { :model => 'unexisting' }
    assert_response :redirect
    assert_redirected_to typus_dashboard_url
  end

  def test_should_render_new
    @request.session[:typus] = 1
    get :new, { :model => 'posts' }
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_item
    @request.session[:typus] = 1
    items = Post.count
    post :create, { :model => 'posts', :item => { :title => "This is another title", :body => "This is the body."}}
    assert_response :redirect
    assert_redirected_to :action => 'edit'
    assert_equal items + 1, Post.count
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
    admin = typus_users(:admin)
    @request.session[:typus] = admin.id
    get :logout
    assert_equal @request.session[:typus], nil
    assert_response :redirect
    assert_redirected_to typus_login_url
  end

  def test_should_perform_a_search
    admin = typus_users(:admin)
    @request.session[:typus] = admin.id
    get :index, { :model => 'posts', :search => 'neinonon' }
    assert_response :success
    assert_template 'index'
  end

  def test_should_allow_admin_add_users
    admin = typus_users(:admin)
    @request.session[:typus] = admin.id
    get :new, { :model => 'typus_users' }
    assert_response :success
  end

  def test_should_not_allow_a_user_add_users
    user = typus_users(:user)
    @request.session[:typus] = user.id
    get :new, { :model => 'typus_users' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_allow_admin_to_edit_himself
    admin = typus_users(:admin)
    @request.session[:typus] = admin.id
    get :edit, { :model => 'typus_users', :id => admin.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_allow_admin_to_edit_other_users
    admin = typus_users(:admin)
    user = typus_users(:user)
    @request.session[:typus] = admin.id
    get :edit, { :model => 'typus_users', :id => user.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_allow_user_to_edit_himself
    user = typus_users(:user)
    @request.session[:typus] = user.id
    get :edit, { :model => 'typus_users', :id => user.id }
    assert_response :success
    assert_template 'edit'
  end

  def test_should_not_allow_uset_to_edit_other_users
    admin = typus_users(:admin)
    user = typus_users(:user)
    @request.session[:typus] = user.id
    get :edit, { :model => 'typus_users', :id => admin.id }
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_should_allow_admin_to_toggle_item
    admin = typus_users(:admin)
    post = posts(:unpublished)
    @request.session[:typus] = admin.id
    get :toggle, { :model => 'posts', :id => post.id, :field => 'status' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert flash[:success]
    assert Post.find(post.id).status
  end

  def test_should_not_allow_user_to_toggle_an_item
    user = typus_users(:user)
    post = posts(:unpublished)
    @request.session[:typus] = user.id
    get :toggle, { :model => 'posts', :id => post.id, :field => 'status' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert flash[:notice]
    assert !Post.find(post.id).status
  end

  def test_should_position_item_one_step_down

    user = typus_users(:user)
    @request.session[:typus] = user.id
    @request.env["HTTP_REFERER"] = "/admin/categories"

    first_category = categories(:first)
    assert_equal first_category.position, 1
    second_category = categories(:second)
    assert_equal second_category.position, 2
    get :position, { :model => 'categories', :id => first_category.id, :go => 'down' }
    assert flash[:success]
    first_category = Category.find(1)
    assert_equal first_category.position, 2
    second_category = Category.find(2)
    assert_equal second_category.position, 1

  end

  def test_should_position_item_one_step_up

    user = typus_users(:user)
    @request.session[:typus] = user.id
    @request.env["HTTP_REFERER"] = "/admin/categories"

    first_category = categories(:first)
    assert_equal first_category.position, 1
    second_category = categories(:second)
    assert_equal second_category.position, 2
    get :position, { :model => 'categories', :id => second_category.id, :go => 'up' }
    assert flash[:success]
    first_category = Category.find(1)
    assert_equal first_category.position, 2
    second_category = Category.find(2)
    assert_equal second_category.position, 1

  end

  def test_should_position_top_item_to_bottom

    user = typus_users(:user)
    @request.session[:typus] = user.id
    @request.env["HTTP_REFERER"] = "/admin/categories"

    first_category = categories(:first)
    assert_equal first_category.position, 1

    get :position, { :model => 'categories', :id => first_category.id, :go => 'bottom' }
    assert flash[:success]

    first_category = Category.find(1)
    assert_equal first_category.position, 3
    
  end

  def test_should_position_bottom_item_to_top

    user = typus_users(:user)
    @request.session[:typus] = user.id
    @request.env["HTTP_REFERER"] = "/admin/categories"

    third_category = categories(:third)
    assert_equal third_category.position, 3

    get :position, { :model => 'categories', :id => third_category.id, :go => 'top' }
    assert flash[:success]

    third_category = Category.find(3)
    assert_equal third_category.position, 1

  end

end
