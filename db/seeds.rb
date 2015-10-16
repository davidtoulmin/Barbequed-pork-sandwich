# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## Create a dummy user
user = User.create!(first_name: "Mat", last_name: "Blair", 
  email: "mathew.blair@unimelb.edu.au", bio: "Some really awesome author that wrote some stuff",
  username: 'mjolkchoklad', password: "testtest")

newspaper = Source.create!(name: "A Newspaper", url: "www.newspaper.com", description: "A boring old newspaper. Does anyone read these anymore?")
journal = Source.create!(name: "Some Glossy Journal", url: "www.journal.com", description: "The sort of trashy magazine you find in the doctor's waiting room")

Source.create!(url: 'http://www.theage.com.au/rssheadlines/political-news/article/rss.xml', name: "TheAge", description: "The Age articles: Latest political news articles. For all the articles, visit http://www.theage.com.au.")
Source.create!(url: 'http://api.nytimes.com/svc/topstories/v1/technology.json?api-key=545f8930f3a92adfd2018cc65ed06865:6:72784832', name: "NYT", description: "With the Times Newswire API, you can get links and metadata for Times articles and blog posts as soon as they are published on NYTimes.com. The Times Newswire API provides an up-to-the-minute stream of published items.")
Source.create!(url: 'http://feeds.bbci.co.uk/news/world/asia/rss.xml', name: "TheBBC", description: "BBC News - Asia: The latest stories from the Asia section of the BBC News web site.")

Article.create!(title: "Sample Article", summary: "This is what an article looks like, blah blah blah", tag_list: "first_article, stuff, things", pubdate: "11-09-2015".to_date, author: "Jeff McJeffers", source: newspaper, image: "www.images.com/image.jpeg", link: "www.newspaper.com/article_1")
Article.create!(title: "Another Article", summary: "This is just a test. Data here for testing", tag_list: "second_article, other_stuff, things", pubdate: "30-09-1986".to_date, author: "Helga Blorp", source: journal, image: "www.other_images.com/other_image.jpeg", link: "www.journal.com/some_article")