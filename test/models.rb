# Define some models ...

class TypusUser < ActiveRecord::Base

end

class Post < ActiveRecord::Base

  validates_presence_of :title, :body
  has_and_belongs_to_many :categories
  has_many :comments
  belongs_to :user

end

class Category < ActiveRecord::Base

  acts_as_list

  validates_presence_of :name
  has_and_belongs_to_many :posts

end

class Comment < ActiveRecord::Base

  validates_presence_of :name, :email, :body
  belongs_to :post

end