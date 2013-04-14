class PlayersController < ApplicationController
  before_filter :not_signed_in, only: [:create, :new]
  before_filter :signed_in_player, only: [:index, :edit, :update, :destroy]
  before_filter :correct_player,   only: [:edit, :update]
  before_filter :admin_player,     only: [:index, :destroy]

  def show
    redirect_to root_url
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(params[:player])
    if @player.save
      @player.send_email_confirmation
      flash[:success] = "Welcome to Push Pickup! Email sent to #{@player.email} to confirm ownership of that email address."
      sign_in @player
      redirect_to root_path 
    else
      render 'new'
    end
  end

  def edit
    #@needs = @player.needs
  end

  def update
    old_email = @player.email
    params[:player].delete :password
    params[:player].delete :password_confirmation
    if @player.update_attributes(params[:player])
      flash[:success] = 'Profile updated'
      if @player.reload.email != old_email
        @player.send_email_confirmation
        flash[:notice] = "Email sent to #{@player.email} to confirm ownership of that email address."
      end
      sign_in @player
      redirect_to root_path 
    else
      render 'edit'
    end
  end

  def index
    @players = Player.paginate(page: params[:page])
  end

  def destroy
    @player = Player.find(params[:id])
    if current_player?(@player)
      redirect_to root_path
    else
      @player.destroy
      flash[:success] = 'Player destroyed'
      redirect_to players_url
    end
  end

  private

    def not_signed_in
      if signed_in?
        redirect_to root_path
      end
    end
    
    def correct_player
      @player = Player.find(params[:id])
      if current_player?(@player)
        @player.signed_in = true
      else
        redirect_to(root_path) 
      end
    end

    def admin_player
      redirect_to(root_path) unless current_player.admin?
    end
end
