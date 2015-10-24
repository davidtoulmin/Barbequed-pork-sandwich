class Article < ActiveRecord::Base
  # Relationship
  belongs_to :source
  has_many :comments

  # Articles can have tags
  acts_as_taggable

  # Sets 10 articles per page
  # self.per_page = 10
end
