# == Schema Information
#
# Table name: fields
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  notes          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  street_address :string(255)
#  zip_code       :string(255)
#  city_id        :integer
#

class Field < ActiveRecord::Base
  attr_accessible :name, :notes, :zip_code, :street_address, :city_id
  belongs_to :city

  validates :name, presence: true
  validates :zip_code, presence: true
  validates :street_address, presence: true
  
end
