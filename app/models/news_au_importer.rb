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
  SOURCE_NAME = 'NewsAU'
  SOURCE_DESCRIPTION = 'News.com.au  National: National News Headlines and Australian News from around the Nation'

  # A news scrape is initialised with dates to scrape from
  def initialize(start_date, end_date)
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: URL, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Scrape the source for news articles between the given dates
  def scrape
    article_list = []
    # open the rss feed
    open(URL) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        # Find published date and check it's in range
        date = item.pubDate.to_datetime
        if (@start < date.to_date) && (@end >= date.to_date)
          # Check uniqueness
          flag = 1
          Article.all.each do |p|
            flag = 0 if p.pubdate == date if p.title == item.title
          end
          if flag == 1
            # Save article with selected attributes
            @article = Article.new(image: item.enclosure.url, title: item.title,
                                   summary: item.description, source: source_name,
                                   link: item.link, pubdate: date)
            @article.save
            article_list.push(@article.id)
          end
        end
      end
    end
    article_list
  end
end
