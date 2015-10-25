# This class is a model to represent the source.
# as it has multiple attributes it needs to be it's own model.

# David Toulmin 638541

class Source < ActiveRecord::Base
  has_many :articles
end
