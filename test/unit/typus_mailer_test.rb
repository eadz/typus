require File.dirname(__FILE__) + '/../test_helper'

class TypusMailerTest < ActiveSupport::TestCase

  def test_should_check_email_contains_application_name_on_subject_and_body
    user = typus_users(:admin)
    response = TypusMailer.deliver_password(user, "12345678", "http://0.0.0.0:3000")
    assert_match /#{Typus::Configuration.options[:app_name]}/, response.subject
    assert_match /#{Typus::Configuration.options[:app_name]}/, response.body
  end

  def test_should_check_contents_of_email_password
    user = typus_users(:admin)
    response = TypusMailer.deliver_password(user, "12345678", "http://0.0.0.0:3000")
    assert_match /You can login at/, response.body
  end

  def test_should_check_email_contains_user_full_name
    user = typus_users(:admin)
    response = TypusMailer.deliver_password(user, "12345678", "http://0.0.0.0:3000")
    assert_match /#{user.full_name}/, response.body
  end

  def test_should_check_email_contains_password
    user = typus_users(:admin)
    response = TypusMailer.deliver_password(user, "12345678", "http://0.0.0.0:3000")
    assert_match /12345678/, response.body
  end

end