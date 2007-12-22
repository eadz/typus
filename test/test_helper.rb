
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
load(File.dirname(__FILE__) + "/schema.rb")
