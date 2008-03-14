
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
ENV['RAILS_ENV'] = "test"
# rails_root = ARGV.shift || File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))
# require "#{rails_root}/config/environment.rb"

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

require 'action_controller/test_process'
#require 'dispatcher'
#require 'breakpoint'

require File.dirname(__FILE__) + "/fixtures/schema"
# require File.dirname(__FILE__) + "/models"

require 'active_record/fixtures'

Fixtures.create_fixtures("#{File.dirname(__FILE__)}/fixtures", ActiveRecord::Base.connection.tables)

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end

class ApplicationController < ActionController::Base
  helper :all
end

# Define some models ...

class TypusUser < ActiveRecord::Base

end

class Post < ActiveRecord::Base

  validates_presence_of :title, :body
  has_and_belongs_to_many :categories
  has_many :comments
  belongs_to :user

  def send_as_newsletter
  end

  def self.cleanup
  end

end

class Category < ActiveRecord::Base

  validates_presence_of :name
  has_and_belongs_to_many :posts

end

class Comment < ActiveRecord::Base

  validates_presence_of :name, :email, :body
  belongs_to :post

end