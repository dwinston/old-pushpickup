class PlayersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update]

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(params[:player])
    if @player.save
      sign_in @player
      flash[:success] = 'Welcome to Push Pickup!'
      redirect_to @player
    else
      render 'new'
    end
  end

  def edit
    @player = Player.find(params[:id])
  end

  def update
    @player = Player.find(params[:id])
    if @player.update_attributes(params[:player])
      flash[:success] = 'Profile updated'
      sign_in @player
      redirect_to @player
    else
      render 'edit'
    end
  end

  private
    
    def signed_in_user
      redirect_to signin_url, notice: 'Please sign in.' unless signed_in?
    end
end
