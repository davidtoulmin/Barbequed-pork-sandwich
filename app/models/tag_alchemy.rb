require 'rubygems'
require 'bundler/setup'
require 'alchemy_api'

class TagAlchemy

  ALCHEMY_API_KEY = '707ef66211a3537da490c059e76979ef12da2043'

  # A tagging method based on the summary
  def initialize article
    @article = article
  end

  # A tagging method based on the summary
  def tag
    tags = []

    article1 = @article.summary + " " + @article.title
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
end