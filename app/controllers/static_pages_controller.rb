require 'will_paginate/array'

class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @availability = current_player.availabilities.build 
      @availability_feed_items = current_player.availability_feed.paginate(page: params[:page])
      @game_feed_items = current_player.game_feed
    end
  end

  def help
  end
  
  def about
  end
end
