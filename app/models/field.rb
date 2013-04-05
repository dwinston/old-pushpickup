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
  has_many :fieldslots
  has_many :games
  has_many :availabilities, through: :fieldslots
  before_destroy :destroy_orphaned_availabilties_and_all_fieldslots

  validates :name, presence: true
  validates :zip_code, presence: true
  validates :street_address, presence: true  

  def self.examples_for_testing
    [{name: "Maxwell Family Field", zip_code: "94720", street_address: "2205 Piedmont Ave", city_name: "Berkeley, CA"},
     {name: "Bushrod Park", zip_code: "94609", street_address: "6051 Racine St", city_name: "Oakland, CA"},
     {name: "Cubberly Field", zip_code: "94306", street_address: "4100 Middlefield Rd", city_name: "Palo Alto, CA", notes: "Enter Cubberley Community Center's south(east) entrance, directly opposite Montrose Avenue, and proceed all the way to the back."}]
  end

  private

    def destroy_orphaned_availabilties_and_all_fieldslots
      self.availabilities.each do |availability|
        availability.destroy if (availability.fields.count == 1) && availability.fields.include?(self)
      end
      self.fieldslots.destroy_all
    end
  
end
