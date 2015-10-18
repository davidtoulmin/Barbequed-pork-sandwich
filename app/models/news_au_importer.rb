# This class imports data from an RSS feed

# David Toulmin 638541

# Require the necessary libraries
require 'Date'
require 'rss'
require 'open-uri'


# Import from NewsAU RSS
class NewsAUImporter

  # URL for RSS feed
  URL = 'http://feeds.news.com.au/public/rss/2.0/news_national_3354.xml'
  TAG_SEARCH_REGEXP = /([A-Z][a-z]+)/
  SOURCE_NAME = "NewsAU"
  SOURCE_DESCRIPTION = "News.com.au  National: National News Headlines and Australian News from around the Nation"


  # A news scrape is initialised with dates to scrape from
  def initialize start_date, end_date
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: URL, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Scrape the source for news articles between the given dates
  def scrape
  #open the rss feed
    open(URL) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        # Find published date and check it's in range
        date = item.pubDate.to_date
        if (@start < date) && (@end >= date)
          # Check uniqueness
          flag = 1
          Article.all.each do |p|
            if p.title == item.title
              if p.pubdate == date
                flag = 0
              end
            end
          end
          if flag == 1
            # Save article with selected attributes
            @article = Article.new( image: item.enclosure.url, title: item.title,
                                       summary: item.description, source: source_name,
                                       link: item.link, pubdate: date)
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
