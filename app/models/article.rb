class Article < ActiveRecord::Base
  # Relationship
  belongs_to :source
  has_many :comments

  # Articles can have tags
  acts_as_taggable

  # Sets 10 articles per page
  self.per_page = 10

  def self.search(search)
    where("title LIKE ?", "%#{search}%")
    where("name LIKE ?", "%#{search}%") 
    where("content LIKE ?", "%#{search}%")
  end
end