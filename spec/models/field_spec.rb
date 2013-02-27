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

require 'spec_helper'

describe Field do

  let(:field) { FactoryGirl.create(:field) }

  subject { field }

  it { should respond_to :name }
  it { should respond_to :street_address }
  it { should respond_to :city }
  it { should respond_to :state_abbr }
  it { should respond_to :zip_code }
  it { should respond_to :notes }

  it { should be_valid }

end
