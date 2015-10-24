require 'rubygems'
require 'bundler/setup'
require 'open_calais'

class TagOpenCalais
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/

  # A tagging method based on the summary
  def initialize(article)
    @article = article
  end

  # A tagging method based on the summary
  def tag
    tags = []
    begin
      article1 = @article.summary + ' ' + @article.title
      oc = OpenCalais::Client.new(api_key: OPEN_CALAIS_API_KEY)
      oc_response = oc.enrich article1
      oc_response.tags.each { |t| tags.push "#{t[:name]}" }
      oc_response.topics.each { |t| tags.push "#{t[:name]}" }
    rescue
      # This catches the exception thrown due to having limited access to the
      # API, due to being on a free account, and I think just ignoring that
      # exception is fine, it's as if I had a full account, and so never got
      # that exception
    end

    tags
  end
end
