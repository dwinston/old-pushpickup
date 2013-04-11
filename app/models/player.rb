# == Schema Information
#
# Table name: players
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  email                      :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  password_digest            :string(255)
#  remember_token             :string(255)
#  admin                      :boolean          default(FALSE)
#  password_reset_token       :string(255)
#  password_reset_sent_at     :datetime
#  activated                  :boolean          default(FALSE)
#  email_confirmation_token   :string(255)
#  email_confirmation_sent_at :datetime
#  subscribed                 :boolean          default(FALSE)
#

class Player < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation, :needs_attributes
  has_secure_password
  has_many :availabilities, dependent: :destroy
  has_many :fields, through: :availabilities
  has_and_belongs_to_many :games

  has_many :needs
  include Needs
  accepts_nested_attributes_for :needs

  need :min_players_in_game, 14 
  need :min_duration_of_game, 45 # minutes
  need :min_days_separating_games, 2
  # Explicitly reference needs to persist them to db
  after_create { registered_need_names.each{|n| get_need(n)} }

  before_save { email.downcase! }
  before_save { generate_token(:remember_token) }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    PlayerMailer.password_reset(self).deliver
  end

  def send_email_confirmation
    generate_token(:email_confirmation_token) 
    self.email_confirmation_sent_at = Time.zone.now
    save!(validate: false)
    PlayerMailer.email_confirmation(self).deliver
  end

  def availability_feed
    availabilities.future.reject(&:unavailability?)
  end
  
  def game_feed
    games.future
  end
  
  private

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while Player.exists?(column => self[column])
    end
end
