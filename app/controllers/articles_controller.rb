class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :authenticate_user
  
  require_relative "../models/importer.rb"
  include Tagger
  #require 'will_paginate/array'

  # GET /articles
  # GET /articles.json
  def index
    # If a search has been made
    if params[:search]
      # Initially sorts articles by pubdate, ideally should handle the case of equal weights later on
      # We do sort by date again to be 100% sure of functionality however
      @articles = Article.all.sort_by { |article| article.pubdate }.reverse
      # Split keywords into an array
      keywords = params[:search].split(" ")
      # Initialise variables for search functionality
      num_articles = Article.all.length
      weights = Array.new(num_articles) {Array.new(2)}
      counter=0
      @articles.each do |article|
        weights[counter][0] = article
        weights[counter][1] = 0
        current_weight = 0
        prev_weight = 0
        # Loop over each keyword
        keywords.each do |keyword|
          if article.tag_list.include? keyword
            weights[counter][1] += 4
          end
          if article.title.include? keyword # try params[:search].in? article.title
            weights[counter][1] += 3
          end
          if article.summary.include? keyword
            weights[counter][1] += 2
          end
          if article.source.name.include? keyword
            weights[counter][1] += 1
          end
          # Check to see if a keyword appeared at all
          current_weight = weights[counter][1]
          if current_weight==prev_weight
            # A keyword didn't appear anywhere, so we don't want to include this article
            # Set the weight to 0, and do not search for anymore keywords
            weights[counter][1] = 0 
            break
          else
            prev_weight=current_weight
          end
        end
        # Increment article
        counter += 1
      end
      # Sort articles by weight in descending order
      weights = weights.sort_by { |article| [article[1], article[0].pubdate]}.reverse
      weighted_articles = []
      for i in 0..num_articles-1
        # Exclude articles that had zero weight
        if weights[i][1]!=0
          weighted_articles[i] = weights[i][0] #accesses article within weights
        end
      end
      # Set weighted articles to articles attribute, ready for rendering
      @articles = weighted_articles
    else
      # Display all articles
      @articles = Article.all.sort_by { |article| article.pubdate }.reverse
    end

    if params[:next] != ''
      for i in 1..params[:next].to_i
      @articles = @articles.drop(10)
      end
    end
    
  end

  
  def my_interests
    @articles = Article.tagged_with(current_user.interest_list, :any => true).to_a
    render 'index'
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    if @article.nil?
      render '/articles/article_not_found'
    end
  end

  # Fetch new articles for the db
  def refresh
    # Find latest published article and scrape from then onwards
    date = ::Date.today - 7
    articles = Article.all
    articles.each do |article|
      if article.pubdate.to_date > date
        date = article.pubdate.to_date
      end
    end
    # Itterate through importers, initialising them, and scraping
    new_articles = []
    Importer.importers.each do |importer_klass|
      imp = importer_klass.new(date, Date.today)
      new_articles.concat(imp.scrape)
    end
    threads_list = []
    counter = 0
    for i in 0...new_articles.length do
      tag_article(Article.where(id: new_articles[i])[0])
      #article_holder = Article.where(id: new_articles[i])[0]
      #threads_list[counter] = Thread.new {tag_article(article_holder)}
      counter += 1
    end
    for i in 0...counter do 
      threads_list[i].join
    end
    # Scrape finished, and redirect to articles
    redirect_to '/articles', notice: 'Succesfully scraped for new articles.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      if Article.where(id: params[:id]).exists?(conditions = :none)
        @article = Article.find(params[:id])
      else
        @article = nil
      end
    end

    def check_auth
      unless @article.can_edit? current_user
        redirect_to @article
      end
    end

    def comment_params
      params.require(:comment).permit(:content)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :summary, :tag_list, :pubdate, :author, :source, :image, :link)
    end

end
