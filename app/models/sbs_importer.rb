# This class is responsible for communicating with the SBS RSS
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

class SBSImporter
  

  def initialize start_date, end_date
    #defining the source model from the database
    @source = Source.find_by(name: source_name)
  end
  
  # Define the method for file_name.
  def source_name
    "SBS"
  end
  
  # Define a scrape method that saves canned article data to the database
  def scrape
    collectdata()
  end
  def collectdata
    url = @source.url
    #Loop through the response.
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        #capturing all desired data from all the items in the feed
        title = item.title
        link =  item.link
        #Defining the author, as it is latest news. No author is accredited.
        author = "SBS National News"
        # Decription contains a source link, and a image link. As well
        # as a summary/description type sentence/paragraph.
        description = item.description
        # Resolving the image link from the description
        image = interpret_get_image(description)
        # Resolving the summary/description from the description item.
        summary = interpret_description(description)
        #converting the Time class returned to a preffered Date object
        date = (item.pubDate).to_datetime
        #SBS Does not have a categories, or related type field to extract tags.
        #So I will extract the proper nouns in the title in an effort to ascertain
        #meaniningful tags related to the articles. A proper noun is one that begins with a capital letter.
        #But does not include the first word or any single capital letters. 
        tags = title.scan(/(?<!^|\. |\.  )[A-Z][a-z]+/)
        article = Article.new(title: title, summary: summary,
          source: @source, link: link, pubdate: date, image: image)
        article.tag_list.add(tags)
        #Checking if the article already exists or not.
        if ((Article.find_by title: title) == nil)
          article.save
        end

      end
    end
  end
  
  def interpret_description description
    #Splitting the description item to find the 'summary'
    description = description.split(/(<br)/)[0]
  end
  
  def interpret_get_image description
    #Splitting the description string, to isolate the image source
    image = description.scan(/(<img src=)(.*?)>/)
    #Splitting the returned array of strings. Extracting the exact link
    image = image[0][1].scan(/("(.*?)"){1}/)
    #Finally returning the string with removed quotations which is the exact
    #url link
    image = image[0][1]
  end
  
end
