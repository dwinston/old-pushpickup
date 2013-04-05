require 'chronic'
require 'chronic_duration'

class AvailabilitiesController < ApplicationController
  before_filter :signed_in_player
  before_filter :correct_player, only: :destroy

  def create

    if params[:availability] && params[:availability][:start_time].is_a?(String)
      start_time = Chronic.parse(params[:availability][:start_time])
      duration = ChronicDuration.parse(params[:availability][:duration],
                                        default_unit: 'minutes')
      duration = (duration / 60).round unless duration.nil? # sec to minutes
      params[:availability][:start_time] = start_time
      params[:availability][:duration] = duration
      session[:availability_params] = nil
    end

    logger.debug "Prior to merge, params is #{params[:availability].inspect}"
    if session[:availability_params]
      params[:availability].update(session[:availability_params]) { |key, v1, v2| v1.concat(v2) } 
    end
    logger.debug "Following merge, params is #{params[:availability].inspect}"

    session[:availability_params] = nil
    @availability = current_player.availabilities.build(params[:availability])
    
    if params[:add_fields]
      @availability.adding_fields = true
      if @availability.valid?
        session[:availability_params] = params[:availability]
        redirect_to fields_path
      else
        @availability_feed_items = []
        @game_feed_items = []
        render 'static_pages/home'
      end
    elsif @availability.save
      flash[:success] = 'Availability created!'
      if !current_player.activated? 
        flash[:alert] = "You are currently unable to help create games through your availabilities."
        if current_player.created_at > 30.days.ago
          flash[:alert] += " Have you confirmed your email address using the link sent to #{current_player.email}?"
        elsif !current_player.subscribed?
          flash[:alert] += " Please consider subscribing for full privileges."
        end
      end
      redirect_to root_url
    else
      @availability_feed_items = []
      @game_feed_items = []
      render 'static_pages/home'
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
end
