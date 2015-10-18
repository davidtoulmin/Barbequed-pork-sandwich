# This class imports data from an RSS feed

# David Toulmin 638541

# Require the necessary libraries
require 'Date'
require 'open-uri'
require 'rss'

# Import from the BBC RSS
class TheBBCImporter

  # URL for RSS feed
  RSS_URL = 'http://feeds.bbci.co.uk/news/world/asia/rss.xml'
  # String that proceeds nice images in a BBC articles
  IMAGE_SEARCH_REGEXP = /<img(.*?)src="http:\/\/ichef(.+?)"/
  # string to complete regexp searched image url
  IMAGE_SEARCH_COMPLETION = "http://ichef"
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/
  SOURCE_NAME = "TheBBC"
  SOURCE_DESCRIPTION = "BBC News - Asia: The latest stories from the Asia section of the BBC News web site."


  # A news scrape is initialised with dates to scrape from
  def initialize start_date, end_date
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: RSS_URL, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Define a scrape method that imports data from an RSS feed
  def scrape
    # Open and parse the rss feed
    url= RSS_URL
    open(url) do |rss|
      feed = RSS::Parser.parse(rss, false)
      feed.items.each do |item|
        # Get publication date and check if it's in range
        date = item.pubDate.to_date
        if (@start < date) && (@end >= date)
          # Search within article for an image, by accessing and parsing the source given
          page_url=item.link
          open(page_url) do |body|
            page = body.read
            image_data = page.scan(IMAGE_SEARCH_REGEXP)
            if image_data!=nil && image_data[0]!=nil
              @image_url = IMAGE_SEARCH_COMPLETION + image_data[0][1]
            else
              @image_url = nil
            end
          end
          # Scrape data from source, using tags from source, and checking for uniqueness
          flag = 1
          Article.all.each do |p|
            if p.title == item.title
              if p.pubdate == date
                flag = 0
              end
            end
          end
          if flag == 1
            # Save article
            @article = Article.new(author: nil, title: item.title, image: @image_url,
              summary: item.description, source: source_name, pubdate: date, link: item.link)
            tag_article @article
            @article.save
          end
        end
      end
    end
  end

  # Search the summary and title for proper nouns to tag on and add these to the list of tags
  private
  def tag_article article
    tags = []
    list = ""
    words = article.summary + ' ' + article.title
    tag_data = words.scan(TAG_SEARCH_REGEXP)
    tag_data.each do |word|
      tags.push word[0]
    end
    tags.uniq.each do |word|
      list += word + ", "
    end
    article.tag_list = list
  end

end