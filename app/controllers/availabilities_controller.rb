class AvailabilitiesController < ApplicationController
  before_filter :signed_in_player
  before_filter :correct_player, only: :destroy

  def index
    redirect_to root_path
  end

  def create
    #params[:availability].update(session[:availability_params]){|key, v1, v2| v1.concat(v2)} if session[:availability_params]
    #session[:availability_params] = nil

    @availability = current_player.availabilities.build(params[:availability])
    
    if params[:add_fields]
      @availability.adding_fields = true
      if @availability.valid?
        session[:availability_params] = params[:availability]
        redirect_to fields_url
      else
        @availability_feed_items = []
        @game_feed_items = []
        if signed_in?
          @availability_feed_items = current_player.availability_feed
          @game_feed_items = current_player.game_feed
        end
        render '/static_pages/home'
      end
    elsif @availability.save
      flash[:success] = make_unavailability ? "Unavailability created!" : 'Availability created!'
      if !current_player.activated? 
        flash[:alert] = "You are currently unable to help create games through your availabilities."
        flash[:alert] += " Have you confirmed your email address using the link sent to #{current_player.email}?"
      end
      redirect_to root_url
    else
      @availability_feed_items = []
      @game_feed_items = []
      if signed_in?
        @availability_feed_items = current_player.availability_feed
        @game_feed_items = current_player.game_feed
      end
      render '/static_pages/home'
    end
  end

  def destroy
    @availability.destroy
    flash[:success] = 'Availability deleted.'
    redirect_to root_url
  end

  private

    def correct_player
      @availability = current_player.availabilities.find_by_id(params[:id])
      redirect_to root_url if @availability.nil?
    end

    def make_unavailability
      current_player.admin? && 
        params[:unavailability] == 'yes' &&
        @availability.fieldslots.each { |fs| fs.update_attributes! open: false, why_not_open: params[:why_not_open] }
    end
end
