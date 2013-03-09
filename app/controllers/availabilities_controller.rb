require 'chronic'
require 'chronic_duration'

class AvailabilitiesController < ApplicationController
  before_filter :signed_in_player
  before_filter :correct_player, only: :destroy

  def create
    if params[:availability][:start_time].is_a?(String)
      start_time = Chronic.parse(params[:availability][:start_time])
      duration = ChronicDuration.parse(params[:availability][:duration],
                                        default_unit: 'minutes')
      duration = (duration / 60).round unless duration.nil? # sec to minutes
      params[:availability][:start_time] = start_time
      params[:availability][:duration] = duration
    end

    @availability = current_player.availabilities.build(params[:availability])
    if @availability.save
      flash[:success] = 'Availability created!'
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @availability.destroy
    redirect_to root_url
  end

  private

    def correct_player
      @availability = current_player.availabilities.find_by_id(params[:id])
      redirect_to root_url if @availability.nil?
    end
end
