# This class searches the summary and title for proper nouns to tag on and add these to the list of tags

# David Toulmin 638541

class Tagger
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/

  # Search the summary and title for proper nouns to tag on and add these to the list of tags
  def tag_article article
    tags = []
    tags += tag_method_one(article)
    tags += tag_method_two(article)
    tags += tag_method_three(article)
    tags += tag_method_four(article)
    tags += tag_method_five(article)
    tags.uniq.each do |word|
      list += word + ", "
    end
    article.tag_list = list
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

    return tags
  end

  def tag_method_four article
    tags = []

    return tags
  end

  def tag_method_five article
    tags = []

    return tags
  end

=begin

this was some of the code used by the NYT scraper to generate tags from the JSON tags,
but not all of them have that, and as we're doing tagging seperately from the scraping
that makes accessing the JSON tags difficult.

  def tag_article article, item
    # The NYT also has convinient tags in the JSON format, so tag on those as well
    NYT_TAGS.each do |tag|
      tag_content = item[tag]
      if tag_content != ""
        if tag_content.is_a?(Array)
          tag_content.each do |tag_subcontent|
            list += tag_subcontent + ", "
          end
        else
          list += tag_content + ", "
        end
      end
    end
    article.tag_list = list
  end
=end

end