class Field < ActiveRecord::Base
  attr_accessible :city, :full_address, :name, :notes

  validates :city, format: { with: /\A[A-Z][a-z]+( [A-Z][a-z]+)*, [A-Z]{2}\z/ }
  validates :full_address, presence: true
  validate :city_is_part_of_full_address
  
  private

    def city_is_part_of_full_address
      embedded_city = full_address.scan(city).shift 
      if embedded_city.nil? 
        errors.add(:full_address, 'must contain city')
      end
    end

end
