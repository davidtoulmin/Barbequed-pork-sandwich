# This class searches the summary and title for proper nouns to tag on and add these to the list of tags

# David Toulmin 638541
require 'rubygems'
require 'bundler/setup'
require 'sentimental'
require 'alchemy_api'
require 'open_calais'

module Tagger
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/
  ALCHEMY_API_KEY = '707ef66211a3537da490c059e76979ef12da2043'
  OPEN_CALAIS_API_KEY = 'zNaGcoGpoxuJ0Se38IjAvQPvqobVRYbb'

  # Search the summary and title for proper nouns to tag on and add these to the list of tags
  def tag_article article
    list = ""
    tags = []
    method_one = Thread.new { tags += tag_method_one(article)}
    method_two = Thread.new { tags += tag_method_two(article)}
    method_three = Thread.new { tags.push(tag_method_three(article))}
    method_four = Thread.new { tags += tag_method_four(article)}
    method_five = Thread.new { tags += tag_method_five(article)}

    method_one.join
    method_two.join
    method_three.join
    method_four.join
    method_five.join

    tags.uniq.each do |word|
      list += word + ", "
    end
    article.tag_list = list
    article.save
  end

  private
  def tag_method_one article
    tags = []
    words = article.summary
    tag_data = words.scan(TAG_SEARCH_REGEXP)
    tag_data.each do |word|
      tags.push word[0]
    end
    return tags
  end

  def tag_method_two article
    tags = []
    words = article.title
    tag_data = words.scan(TAG_SEARCH_REGEXP)
    tag_data.each do |word|
      tags.push word[0]
    end
    return tags
  end

  def tag_method_three article
    tags = []
    Sentimental.load_defaults
    Sentimental.threshold = 0.1

    article1 = article.summary + article.title
    s = Sentimental.new
    result = s.get_sentiment article1
    if (result == :negative)
      return "negative"
    else
      return "positive"
    end
  end

  def tag_method_four article
    tags = []

    article1 = article.summary + article.title
    AlchemyAPI.key = ALCHEMY_API_KEY
    a_entities = AlchemyAPI::EntityExtraction.new.search(text: article1)
    if a_entities
      a_entities.each { |e| tags.push "#{e['text']}" }
    end
    a_concepts = AlchemyAPI::ConceptTagging.new.search(text: article1)
    if a_concepts
      a_concepts.each { |c| tags.push "#{c['text']}" }
    end

    return tags
  end

  def tag_method_five article
    tags = []
    begin
      article1 = article.summary + article.title
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

    return tags
  end
end