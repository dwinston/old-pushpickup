class Field < ActiveRecord::Base
  attr_accessible :city, :full_address, :name, :notes
end
