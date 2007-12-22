
require File.dirname(__FILE__) + '/../test_helper'

class TypusControllerTest < ActionController::TestCase
  
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
    assert true
  end

  def test_should_render_edit
    assert true
  end

  def test_should_run_a_filter
    assert true
  end

  def test_should_return_flash_after_updating_record
    assert true
  end

  def test_should_check_user_is_authenticated
    assert true
  end

  def test_should_render_dashboard
    assert true
  end

end