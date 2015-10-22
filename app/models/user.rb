class User < ActiveRecord::Base
  # Validations
  validates_presence_of :email, :first_name, :last_name, :username, :password
  validates :email, format: { with: /(.+)@(.+).[a-z]{2,4}/, message: "%{value} is not a valid email" }
  validates :username, :first_name, :last_name, format: { with: /\A[A-Za-z]{2,}\z/, message: "%{value} is not a valid input" }
  validates :username, :email, uniqueness: true
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => {:within => 8..40},
                       :on => :create
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => {:within => 8..40},
                       :on => :update

  # Users can have interests
  acts_as_taggable_on :interests

  # Use secure oasswords
  has_secure_password

  #Users own comments
  has_many :comments

  # Find a user by username, then check the username is the same
  def self.authenticate password, username
    user = User.find_by(username: username)
    if user && user.authenticate(password)
      return user
    else
      return nil
    end
  end

  # Return the user's full name
  def full_name
    first_name + ' ' + last_name
  end
end
