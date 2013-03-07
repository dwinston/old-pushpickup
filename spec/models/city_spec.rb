# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe City do

  let(:city) { FactoryGirl.create(:city) }

  subject { city }

  it { should respond_to :name }
  it { should respond_to :fields }

  it { should be_valid }
  
  describe 'when destroyed' do
    before do
      FactoryGirl.create(:field, city: city)
      FactoryGirl.create(:field, city: city)
    end

    it 'has a couple fields now' do
      city.fields.count.should == 2
    end

    it "should destroy associated fields" do
      fields = city.fields.dup
      city.destroy
      fields.should_not be_empty
      fields.each do |field|
        Field.find_by_id(field.id).should be_nil
      end
    end
  end
end
