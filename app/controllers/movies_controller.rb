class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # bring ratings values
    m = Movie.new
    @all_ratings = m.ratings_values
    
    #debugger
    if params[:selected].nil? and params[:ratings].nil? and not session[:selected].nil?
      tmp = session[:selected]
      session.delete(:selected)
      flash.keep
      redirect_to movies_path(selected: tmp)
    end
    if params[:ratings].nil? and params[:selected].nil? and not session[:ratings].nil?
      tmp = session[:ratings]
      session.delete(:ratings)
      flash.keep
      redirect_to movies_path(ratings: tmp)
    end
    
    if not params[:selected].nil? 
      session[:selected] = params[:selected] if params[:selected] != session[:selected]
      session[:selected] ||= params[:selected]
      params[:selected] ||= session[:selected]
      session.delete(:ratings)
    end
    if not params[:ratings].nil? 
      session[:ratings] = params[:ratings] if params[:ratings] != session[:ratings]
      session[:ratings] ||= params[:ratings]
      params[:ratings] ||= session[:ratings]
      session.delete(:selected)
    end
    
    # get checked values
    @checked = Hash.new(false)
    params[:ratings].each_key { |key| @checked[key] = true } if params[:ratings] != nil
    
    # get title and release dates filters
    case params[:selected]
    when 'M'
      @movies = Movie.find(:all, :order => :title)
      @title_header = 'hilite'
    when 'R'
      @movies = Movie.find(:all, :order => :release_date)
      @release_date_header = 'hilite'
    else
      @movies = Movie.all if params[:ratings] == nil
      @movies = Movie.find(:all, :conditions => { :rating => params[:ratings].keys }) if params[:ratings] != nil
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
