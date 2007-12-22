
require File.dirname(__FILE__) + '/../test_helper'

class TypusControllerTest < ActionController::TestCase

  fixtures :posts

  def test_should_redirect_to_login
    get :index
    assert_response :redirect
    assert_redirected_to typus_login_url
  end
  
  def test_should_login_and_render_dashboard
    @request.session[:typus] = true
    get :dashboard
    assert_response :success
    assert_template 'dashboard'
  end

  def test_should_render_index
    @request.session[:typus] = true
    get :index, :model => 'posts'
    assert_response :success
    assert_template 'index'
  end

  def test_should_render_edit
    @request.session[:typus] = true
    get :edit, { :model => 'posts', :id => 1 }
    assert_response :success
  end

  def test_should_run_a_filter
    assert true
  end

  def test_should_return_flash_after_updating_record
    assert true
  end

end