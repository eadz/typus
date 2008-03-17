require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/models/typus_user'

class TypusUserTest < ActiveSupport::TestCase

  def test_check_email_format
    typus_user = new_typus_user
    typus_user.email = "admin"
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:email)
  end

  def test_should_verify_email_is_unique
    typus_user = new_typus_user
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:email)
  end

  def test_should_verify_typus_user_has_first_name_and_last_name
    typus_user = new_typus_user
    typus_user.first_name = ""
    typus_user.last_name = ""
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:first_name)
    assert typus_user.errors.invalid?(:last_name)
  end

  def test_should_verify_lenght_of_password
    typus_user = new_typus_user
    typus_user.password = "1234"
    typus_user.password_confirmation = "1234"
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:password)
    typus_user.password = "1234567812345678123456781234567812345678123456781234567812345678"
    typus_user.password_confirmation = "12345678123456781234567812345678123456781234567812345678"
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:password)
  end

  def test_should_verify_confirmation_of_password
    typus_user = new_typus_user
    typus_user.password = "12345678"
    typus_user.password_confirmation = "87654321"
    assert !typus_user.valid?
    assert typus_user.errors.invalid?(:password)
  end

protected

  def new_typus_user(options = {})
    TypusUser.new({:email => "admin@typus.org", 
                   :password => "12345678", 
                   :password_confirmation => "12345678", 
                   :first_name => "Admin", 
                   :last_name => "Typus"}.merge(options))
  end

end