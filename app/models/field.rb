# == Schema Information
#
# Table name: fields
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  city           :string(255)
#  notes          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  street_address :string(255)
#  state_abbr     :string(255)
#  zip_code       :string(255)
#

class Field < ActiveRecord::Base
  attr_accessible :city, :state_abbr, :name, :notes, :zip_code, :street_address

  before_save { state_abbr.upcase! } 
  before_save { |field| field.city = field.city.titlecase }

  validates :city, format: { with: /\A[A-Z][a-z]+( [A-Z][a-z]+)*\z/i }
  validates :state_abbr, format: { with: /\A[A-Z]{2}\z/i }
  validates :name, presence: true
  validates :zip_code, presence: true
  validates :street_address, presence: true
  
end
