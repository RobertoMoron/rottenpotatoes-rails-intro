class MoviesController < ApplicationController

  def show 
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.all_ratings
    
#     Original filter
#     if params[:ratings].nil? && session[:ratings].nil? 
#       @ratings_to_show = []
#     elsif !params[:ratings].nil?
#       @ratings_to_show = params[:ratings].keys
#     elsif !session[:ratings].nil? && 
#     end
#     session[:ratings] = @ratings_to_show
    
    #Filter assignment
    if (params[:ratings].nil? && session[:ratings].nil?) #|| (!session[:ratings].nil? && params[:ratings].nil?)
      session[:ratings] = @all_ratings
    elsif (!params[:ratings].nil? && session[:ratings].nil?) || (!session[:ratings].nil? && !params[:ratings].nil? && session[:ratings] != params[:ratings])
      session[:ratings] = params[:ratings].keys
    end
    
    #Redirect if params has no sorting or filtering settings
    if params[:ratings].nil? && params[:sort].nil?
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end
    
    #Filtered movies
    @ratings_to_show = session[:ratings]
    @ratings_to_show_hashmap = Hash[session[:ratings].map {|el| [el, 1]}]
    @movies = Movie.with_ratings(session[:ratings]) 
    
    #Order assignment
    if (!params[:sort].nil? && session[:sort].nil?) || (!params[:sort].nil? && !session[:sort].nil? && session[:sort] != params[:sort])
      session[:sort] = params[:sort]
    end 
    
    #Sorting
    if session[:sort] == 'title' 
      @movies = @movies.order(session[:sort])
      @title_classes = 'hilite bg-warning' 
    elsif session[:sort] == 'release_date'
      @movies = @movies.order(session[:sort])
      @release_date_classes = 'hilite bg-warning' 
    end    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
