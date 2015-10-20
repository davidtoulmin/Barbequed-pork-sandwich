class Article < ActiveRecord::Base
  # Relationship
  belongs_to :source
  has_many :comments

  # Articles can have tags
  acts_as_taggable
end
