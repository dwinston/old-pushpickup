class CitiesController < ApplicationController
  before_filter :signed_in_player
  before_filter :admin_player  

  def index
    @cities = City.all
    store_location
  end

  def new
    @city = City.new
  end

  def create
    @city = City.new(params[:city])
    if @city.save
      flash[:success] = 'City created!'
      redirect_back_or root_url
    else
      render 'new'
    end
  end

  def destroy
    @city = City.find(params[:id]).destroy
    flash[:success] = 'City destroyed'
    redirect_back_or root_url
  end

  private

    def admin_player
      redirect_to(root_path) unless current_player.admin?
    end

end
