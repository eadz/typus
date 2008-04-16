require File.dirname(__FILE__) + '/../test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  def test_should_return_model_fields_for_typus_user
    fields = TypusUser.model_fields
    expected_fields = [["id", "integer"], 
                       ["email", "string"], 
                       ["first_name", "string"], 
                       ["last_name", "string"], 
                       ["salt", "string"], 
                       ["crypted_password", "string"], 
                       ["status", "boolean"], 
                       ["admin", "boolean"], 
                       ["created_at", "datetime"], 
                       ["updated_at", "datetime"]]
    assert_equal fields, expected_fields
  end

  def test_should_return_typus_fields_for_list_for_typus_user
    fields = TypusUser.typus_fields_for('list')
    expected_fields = [["first_name", "string"], 
                       ["last_name", "string"], 
                       ["email", "string"], 
                       ["status", "boolean"], 
                       ["admin", "boolean"]]
    assert_equal fields, expected_fields
    assert_equal expected_fields.class, Array
  end

  def test_should_return_typus_fields_for_form_for_typus_user
    fields = TypusUser.typus_fields_for('form')
    expected_fields = [["first_name", "string"], 
                       ["last_name", "string"], 
                       ["email", "string"], 
                       ["password", "password"], 
                       ["password_confirmation", "password"]]
    assert_equal fields, expected_fields
    assert_equal expected_fields.class, Array
  end

  def test_should_return_typus_fields_for_relationship_for_typus_user
    fields = TypusUser.typus_fields_for('relationship')
    expected_fields = [["first_name", "string"], 
                       ["last_name", "string"], 
                       ["email", "string"], 
                       ["status", "boolean"], 
                       ["admin", "boolean"]]
    assert_equal fields, expected_fields
    assert_equal expected_fields.class, Array
  end

  def test_should_return_filters_for_typus_user
    filters = TypusUser.typus_filters
    expected_filters = [["status", "boolean"]]
    assert_equal filters, expected_filters
    assert_equal expected_filters.class, Array
  end

  def test_should_return_actions_on_list_for_typus_user
    actions = TypusUser.typus_actions_for('list')
    expected_actions = []
    assert_equal actions, expected_actions
    assert_equal expected_actions.class, Array
  end

  def test_should_return_actions_on_list_for_post
    actions = Post.typus_actions_for('list')
    expected_actions = [ "cleanup" ]
    assert_equal actions, expected_actions
    assert_equal expected_actions.class, Array
  end

  def test_should_return_actions_on_form_for_post
    actions = Post.typus_actions_for('form')
    expected_actions = [ "send_as_newsletter", "preview" ]
    assert_equal actions, expected_actions
    assert_equal expected_actions.class, Array
  end

  def test_should_return_order_by_for_model
    order = Post.typus_order_by
    expected_order = "title ASC, created_at DESC"
    assert_equal order, expected_order
    assert_equal expected_order.class, String
  end

end