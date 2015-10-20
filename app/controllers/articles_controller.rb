class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :authenticate_user
  
  include Importer
  include Tagger
  require 'will_paginate/array'

  # GET /articles
  # GET /articles.json
  def index
    #@articles = Article.all.reverse
    #Ensuring all articles are displayed from most recent first.
    @articles = Article.all.sort_by { |article| article.pubdate }.reverse
    @articles = Article.paginate(:page => params[:page], :per_page => 10)
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
    importers.each do |importer_klass|
      imp = importer_klass.new(date, Date.today)
      imp.scrape
    end
    Article.all.each do |a|
      if a.created_at.to_date >= date
        tag_article a
        a.save
      end
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
