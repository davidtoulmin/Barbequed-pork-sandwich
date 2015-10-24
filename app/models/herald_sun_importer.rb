# This class is responsible for communicating with the heraldsun RSS
# feed in order to scrape the data from the feed. It will create objects
# of Type article holding desired attributes from the feed.
#
# Author::    Leonidas Skopilianos (skl@student.unimelb.edu.au)
# Copyright:: Copyright (c) 2015 Leonidas Skopilianos
# Completed in Partial Completion of SWEN30006
# At: The University Of Melbourne
#
#
require 'rss'
require 'json'
require 'open-uri'
require 'Date'

class HeraldSunImporter
  def initialize(_start_date, _end_date)
    # Defining the instance variable of the source of the article
    @source = Source.find_by(name: source_name)
  end

  # Defining the class name method for use in the initialize.
  def source_name
    'The Herald Sun'
  end

  # Define the method that is responsible for collecting and interpretting
  # the data.
  def scrape
    collectdata
  end

  # This method is responsible for extracting the data from the RSS feed.
  # It accesses it, and parses the RSS file format by accessing desirable
  # attributes. It will then create the article objects from the information
  # and add them to an Article array.
  # Given the RSS feed returns the data in a very accessible form, very little/no
  # interpreting will be required.
  def collectdata
    article_list = []
    # Defining the url
    url = @source.url
    # opening the RSS feed and handeling any
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      counter = 0

      # for each item in the feed (i.e each article)
      feed.items.each do |item|
        # Collect attributes of each item. There is very little need for interpretation.
        # most items are given as desired.
        title = item.title
        link =  item.link
        description = item.description
        author = 'Herald Sun Breaking News'
        date = (item.pubDate).to_datetime

        # Defining a new article object
        article = Article.new(title: title, summary: description,
                              link: link, source: @source, pubdate: date, author: author)
        if (Article.find_by title: title).nil?
          # Checking if the article already exists or not.
          article.save
          article_list.push(article.id)
        end
      end
    end
    article_list
  end
end
