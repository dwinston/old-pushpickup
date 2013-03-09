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

require 'spec_helper'

describe Fieldslot do

  let(:player) { FactoryGirl.create :player }
  let(:field) { FactoryGirl.create :field }
  let(:availability) { FactoryGirl.create :availability, player: player }
  let(:fieldslot) { FactoryGirl.create :fieldslot, field: field, availability: availability }

  subject { fieldslot }

  it { should respond_to :field }
  it { should respond_to :availability }
  it { should respond_to :open }
  it { should respond_to :why_not_open }

  it { should be_open }
  
end
