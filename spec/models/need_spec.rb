# == Schema Information
#
# Table name: needs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  player_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  value      :integer
#

require 'spec_helper'

describe Need do

  let(:need) { FactoryGirl.create(:need) }

  subject { need }

  it { should respond_to :name }
  it { should respond_to :value }
  it { should respond_to :player }

  it { should be_valid }
end
