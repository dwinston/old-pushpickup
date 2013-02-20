class PlayersController < ApplicationController
  before_filter :signed_in_player, only: [:index, :edit, :update, :destroy]
  before_filter :correct_player,   only: [:edit, :update]
  before_filter :admin_player,     only: :destroy

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

  def index
    @players = Player.paginate(page: params[:page])
  end

  def destroy
    @player.destroy
    flash[:success] = 'Player destroyed'
    redirect_to players_url
  end

  private
    
    def signed_in_player
      unless signed_in?
        store_location
        redirect_to signin_url, notice: 'Please sign in.'
      end
    end

    def correct_player
      @player = Player.find(params[:id])
      redirect_to(root_path) unless current_player?(@player)
    end

    def admin_player
      @player = Player.find(params[:id])
      redirect_to(root_path) unless current_player.admin? && !current_player?(@player)
    end
end
