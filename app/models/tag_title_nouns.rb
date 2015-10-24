class TagTitleNouns
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/

  # A tagging method based on the summary
  def initialize(article)
    @article = article
  end

  # A tagging method based on the summary
  def tag
    tags = []
    words = @article.title
    tag_data = words.scan(TAG_SEARCH_REGEXP)
    tag_data.each do |word|
      tags.push word[0]
    end
    tags
  end
end
