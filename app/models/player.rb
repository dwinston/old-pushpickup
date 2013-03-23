# == Schema Information
#
# Table name: players
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class Player < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  has_many :availabilities, dependent: :destroy
  has_many :fields, through: :availabilities
  has_and_belongs_to_many :games

  include Needs

  need :min_players_in_game, 14 
  need :min_duration_of_game, 45 # minutes
  need :min_days_separating_games, 2
  # Explicitly reference needs to persist them to db
  after_create { registered_need_names.each{|n| get_need(n)} }

  before_save { email.downcase! }
  before_save :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  def availability_feed
    Availability.where("player_id = ? AND start_time > ?", id, DateTime.now)
  end
  
  def game_feed
    games.where("start_time > ?", DateTime.now) 
  end
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
