# == Schema Information
#
# Table name: fieldslots
#
#  id              :integer          not null, primary key
#  availability_id :integer
#  field_id        :integer
#  open            :boolean          default(TRUE)
#  why_not_open    :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Fieldslot < ActiveRecord::Base
  attr_accessible :open, :why_not_open, :field_id
  belongs_to :availability
  belongs_to :field
end
