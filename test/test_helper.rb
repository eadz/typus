
ENV['RAILS_ENV'] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

require 'test/unit'
require 'action_controller/test_process'
require 'active_record/fixtures'

require File.dirname(__FILE__) + "/fixtures/schema"
require File.dirname(__FILE__) + "/models"

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end

class ApplicationController < ActionController::Base
  helper :all
end