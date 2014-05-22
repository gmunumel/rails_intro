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
    
    # get checked values
    @checked = Hash.new(false)
    
    redirect = false
    
    if params[:selected].nil? and params[:ratings].nil? and 
        session[:selected].nil? and session[:ratings].nil? 
      params[:ratings] = {"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"} 
      redirect = true
    end
    
    if params[:selected].nil? and not session[:selected].nil?
      params[:selected] = session[:selected]
      redirect = true
    elsif params[:selected] != session[:selected]
      session[:selected] = params[:selected]
      redirect = true
    end
    if params[:ratings].nil? and not session[:ratings].nil?
      params[:ratings] = session[:ratings]
      redirect = true
    elsif params[:ratings] != session[:ratings]
      session[:ratings] = params[:ratings]
      redirect = true
    end

    params[:ratings].each_key { |key| @checked[key] = true } if params[:ratings] != nil
    
    # get title and release dates filters
    case params[:selected]
    when 'M'
      @movies = Movie.find(:all, :conditions => { :rating => params[:ratings].keys }, :order => :title)
      @title_header = 'hilite'
    when 'R'
      @movies = Movie.find(:all, :conditions => { :rating => params[:ratings].keys }, :order => :release_date)
      @release_date_header = 'hilite'
    else
      @movies = Movie.find(:all, :conditions => { :rating => params[:ratings].keys }) 
    end
    
    if redirect
      redirect_to movies_path(selected: params[:selected], ratings: params[:ratings])
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
