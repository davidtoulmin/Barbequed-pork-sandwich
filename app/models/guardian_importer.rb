# This is the importer class to import data from a JSON feed

# David Toulmin 638541

# Require the necessary libraries
require 'Date'
require 'open-uri'
require 'json'
require 'net/http'

# Import from Guardian JSON API
class GuardianImporter
  # The Guardian api url
  URL = 'http://content.guardianapis.com/'
  # URL addition for json
  API_KEY = '/search?api-key=a8cmjya9kseh5cvx2k2t6dqn&show-fields=all'
  SUMMARY_SEARCHING_REGEXP = /<("[^"]*"|'[^']*'|[^'">])*>/
  SOURCE_DESCRIPTION = 'The Guardian news api'
  SOURCE_NAME = 'TheGuardian'

  # A news scrape is initialised with dates to scrape from
  def initialize(start_date, end_date)
    @start = start_date
    @end = end_date
  end

  # Returns the source
  def source_name
    Source.where(name: SOURCE_NAME, url: URL + API_KEY, description: SOURCE_DESCRIPTION).first_or_create
  end

  # Scrape the source for news articles between the given dates
  def scrape
    # Open and parse the JSON feed
    uri = URI.parse(URL)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.send_request('GET', API_KEY)
    json_data = JSON.parse(response.body)
    article_list = json_data['response']['results']
    processed_articles = []
    article_list.each do |item|
      # Find published date and check it's in range
      a_date = DateTime.parse(item['webPublicationDate'])
      if (@start.to_date < a_date.to_date) && (@end.to_date >= a_date.to_date)
        # Select attributes
        a_title = item['webTitle']
        a_summary = item['fields']['body']
        a_summary.gsub!(SUMMARY_SEARCHING_REGEXP, '')
        a_summary = a_summary[0...400]
        a_source = source_name
        a_link = item['webUrl']
        a_author = item['fields']['byline']
        a_images = item['fields']['thumbnail']
        # Check uniqueness
        flag = 1
        Article.all.each do |p|
          flag = 0 if p.pubdate == a_date if p.title == a_title
        end
        if flag == 1
          # Save article
          article = Article.new(title: a_title, summary: a_summary,
                                source: a_source, pubdate: a_date.to_datetime,
                                image: a_images, author: a_author,
                                link: a_link)
          processed_articles.push(article.id) if article.save
        end

      end
    end
    processed_articles
  end
end
