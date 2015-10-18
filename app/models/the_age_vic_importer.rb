# This class imports data from an RSS feed

# David Toulmin 638541

# Require the necessary libraries
require 'Date'
require 'open-uri'
require 'rss'

# Import from The Age Victoria
class TheAgeVicImporter

  # URL for RSS feed
  RSS_URL = 'http://www.theage.com.au/rssheadlines/victoria/article/rss.xml'
  SUMMARY_REGEXP = /<p>.+<\/p>/
  IMAGE_REGEXP = /img src="(.+)" width/
  SOURCE_NAME = "TheAgeVic"
  SOURCE_DESCRIPTION = "The Age articles: Latest victoria articles. For all the articles, visit http://www.theage.com.au."

  # A news scrape is initialised with the start and end date, it
  def initialize start_date, end_date
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: RSS_URL, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Define a scrape method that imports data from an RSS feed between the given dates
  def scrape
    # Open and parse the rss feed
    url= RSS_URL
    open(url) do |rss|
      feed = RSS::Parser.parse(rss, false)
      feed.items.each do |item|
        # Get publication date and check if it's in range
        date = item.pubDate.to_date
        if (@start < date) && (@end >= date)
          # Check for uniqueness
          flag = 1
          Article.all.each do |p|
            if p.title == item.title
              if p.pubdate == date
                flag = 0
              end
            end
          end
          if flag == 1
            @article = Article.new()
            # Select attributes
            @article.title = item.title
            @article.author = nil
            @article.summary = item.description.gsub(SUMMARY_REGEXP, "")
            @article.pubdate = date
            @article.source = source_name
            @article.image = item.description.scan(IMAGE_REGEXP)[0][0]
            @article.link = item.link
            # Save article
            @article.save
          end
        end
      end
    end
  end
end