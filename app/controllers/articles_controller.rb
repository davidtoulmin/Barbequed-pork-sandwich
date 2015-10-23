class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :authenticate_user
  
  include Importer
  include Tagger
  #require 'will_paginate/array'

  # GET /articles
  # GET /articles.json
  def index
    #@articles = Article.all.reverse
    #Ensuring all articles are displayed from most recent first.
    @articles = Article.all
    if params[:search]
      #@articles = Article.tagged_with(params[:search], :any => true)
      #@articles = Article.find(:all, :conditions => ["name LIKE ?", "%#{params[:search]}%"])
      #@articles = Article.all.find_by(tag_list: params[:search])#.order("created_at DESC")
    else
      
      #@articles = Article.paginate(:page => params[:page], :per_page => 10)
    end
    #Display 10 articles per page
    

    


    @articles = Article.all.sort_by { |article| article.pubdate }.reverse
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
    importers.each do |importer_klass|
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
