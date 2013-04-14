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

  describe 'with an invalid name' do
    before { city.name = 'Beehive, Mass.' }
    it { should_not be_valid }
  end
  
  describe 'with a couple fields' do
    before do
      city.fields.create(Field.examples_for_testing.sample.reject!{|k,v| k == :city_name})
      city.fields.create(Field.examples_for_testing.sample.reject!{|k,v| k == :city_name})
    end

    it 'has a couple fields now' do
      city.fields.count.should == 2
    end

    it "should destroy associated fields when city is destroyed" do
      fields = city.fields.dup
      city.destroy
      fields.should_not be_empty
      fields.each do |field|
        Field.find_by_id(field.id).should be_nil
      end
    end
  end
end
