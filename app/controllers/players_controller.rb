class PlayersController < ApplicationController
  before_filter :signed_in_player, only: [:edit, :update]
  before_filter :correct_player, only: [:edit, :update]

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
  end

  def update
    if @player.update_attributes(params[:player])
      flash[:success] = 'Profile updated'
      sign_in @player
      redirect_to @player
    else
      render 'edit'
    end
  end

  private
    
    def signed_in_player
      redirect_to signin_url, notice: 'Please sign in.' unless signed_in?
    end

    def correct_player
      @player = Player.find(params[:id])
      redirect_to(root_path) unless current_player?(@player)
    end
end
