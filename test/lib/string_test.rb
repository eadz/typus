require File.dirname(__FILE__) + '/../test_helper'

class StringTest < Test::Unit::TestCase

  def test_should_return_sql_conditions_on_search_for_typus_user
    query = "search=francesc"
    processed = query.build_conditions(TypusUser)
    expected = "AND (LOWER(first_name) LIKE '%francesc%' OR LOWER(last_name) LIKE '%francesc%' OR LOWER(email) LIKE '%francesc%') "
    assert_equal processed, expected
  end
  
  def test_should_return_sql_conditions_on_search_and_filter_for_typus_user
    query = "search=francesc&status=true"
    processed = query.build_conditions(TypusUser)
    expected = "AND (LOWER(first_name) LIKE '%francesc%' OR LOWER(last_name) LIKE '%francesc%' OR LOWER(email) LIKE '%francesc%') AND status = '1' "
    assert_equal processed, expected
  end

  def test_should_return_sql_conditions_on_search_for_post
    query = "search=pum"
    processed = query.build_conditions(Post)
    expected = "AND (LOWER(title) LIKE '%pum%') "
    assert_equal processed, expected
  end

  def test_modelize
    assert "people".modelize, Person
    assert "categories".modelize, Category
    assert "typus_users".modelize, TypusUser
  end

end