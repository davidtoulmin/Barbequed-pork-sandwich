# This class is responsible for communicating with the Sydney Morning Herald RSS
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

class SydneyMorningHeraldImporter
  def initialize(_start_date, _end_date)
    # Defining the instance variable to define the source from the database
    @source = Source.find_by(name: source_name)
  end

  # Define the method for file_name
  def source_name
    'Sydney Morning Herald'
  end

  # Define a scrape method that saves canned article data to the database
  def scrape
    collectdata
  end

  def collectdata
    article_list = []
    # Define the url, then open it.
    url = @source.url
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      counter = 0
      # for each item in the feed extract data.
      feed.items.each do |item|
        # capturing all desired data from all the items in the feed
        title = item.title
        link =  item.link
        # Decription contains a source link, and a image link. As well
        # Resolving the image link from the description
        image = interpret_get_image(item.description)

        # Resolving the summary/description from the description item.
        description = interpret_description(item.description)
        # There is no author field, as it is latest news. Define the author
        author = 'SMH'
        puts(item.pubDate)
        # converting the Time class returned to a preffered Date object
        date = (item.pubDate).to_datetime
        # Defining the source.
        source = 'Sydney Morning Herald'
        article = Article.new(title: title, summary: description,
                              source: @source, link: link, pubdate: date, image: image, author: author)
        # Checking if the article already exists or not.
        if (Article.find_by title: title).nil?
          # Saving the article to the database.
          article.save
          article_list.push(article.id)
        end
      end
    end
    article_list
  end

  def interpret_description(description)
    # Splitting the description item to find the 'summary'
    description = description.split('</p>')[1]
  end

  def interpret_get_image(description)
    # Splitting the description string, to isolate the image source
    image = description.split('<p><img src=')[1]
    image = description.split('/></p>')[0]
    # Determinig if image actually exists.
    unless image.nil?
      # Removing the qoutations around the url.
      image = image.tr('"', '')
      # removing annoying <p><img src= from the front of the url.
      image = image.split('<p><img src=')[1]
      image = image.split('width=')[0]
    end
  end
end
