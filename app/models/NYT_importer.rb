# This is the importer class to import data from a JSON feed

# David Toulmin 638541

# Require the necessary libraries
require 'Date'
require 'open-uri'
require 'json'
require 'net/http'

# Import from NYT JSON API
class NYTImporter
  
  # The NY Times api url
  URL = 'http://api.nytimes.com/'
  # Key for retrieving results
  RESULT_KEY = 'results'
  # URL addition for technology json
  API_KEY = '/svc/topstories/v1/technology.json?api-key=545f8930f3a92adfd2018cc65ed06865:6:72784832'
  SOURCE_DESCRIPTION = "With the Times Newswire API, you can get links and metadata for Times articles and blog posts as soon as they are published on NYTimes.com. The Times Newswire API provides an up-to-the-minute stream of published items."
  SOURCE_NAME = "NYT"
  NYT_TAGS = ["section","subsection","material_type_facet","kicker","des_facet","org_facet","per_facet","geo_facet"]

  # A news scrape is initialised with dates to scrape from
  def initialize start_date, end_date
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: URL + API_KEY, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Define a scrape method that imports data from a JSON feed
  def scrape
    # Open and parse the JSON feed
    uri = URI.parse(URL)
    http = Net::HTTP.new(uri.host, uri.port)
    request_url = API_KEY
    response = http.send_request('GET', request_url)
    forecast = JSON.parse(response.body)
    forecast[RESULT_KEY].each do |item|
      # Get publication date and check if it's in range
      date = DateTime.parse item['published_date']
      if (@start < date.to_date) && (@end >= date.to_date)
        image_url = item['multimedia'][0]
        if(image_url!=nil)
          image_url=image_url['url']
        end
          # Scrape data from source, using tags from source, and checking for uniqueness
        author = item['byline'].gsub('By ','').split(/(\W)/).map(&:capitalize).join
        flag = 1
        Article.all.each do |p|
          if p.title == item['title']
            if p.pubdate == date
              flag = 0
            end
          end
        end
        if flag == 1
          @article = Article.new()
          # Select attributes
          @article.title = item['title']
          @article.author = author
          @article.summary = item['abstract']
          @article.pubdate = date.to_datetime
          @article.source = source_name
          @article.image = image_url
          @article.link = item['url']
          # Save article
          @article.save
        end
      end
    end
  end
end