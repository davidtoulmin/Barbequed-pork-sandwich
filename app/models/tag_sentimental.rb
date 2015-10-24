require 'rubygems'
require 'bundler/setup'
require 'sentimental'

class TagSentimental
  # A tagging method based on the summary
  def initialize(article)
    @article = article
  end

  # A tagging method based on the summary
  def tag
    tags = []
    Sentimental.load_defaults
    Sentimental.threshold = 0.1

    article1 = @article.summary + ' ' + @article.title
    s = Sentimental.new
    result = s.get_sentiment article1
    if (result == :negative)
      return 'negative'
    else
      return 'positive'
    end
  end
end
