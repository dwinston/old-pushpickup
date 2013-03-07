# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class City < ActiveRecord::Base
  attr_accessible :name
  has_many :fields, dependent: :destroy

  validates :name, format: { with: /\A[A-Z][a-z']+( [A-Z][a-z']+)*, [A-Z]{2}\z/,
                             message: 'Use title case and two-letter state abbreviation.
                                       For example: "Los Angeles, CA"'}
end
