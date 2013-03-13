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

require 'spec_helper'

describe Field do

  let(:field) { FactoryGirl.create(:field) }

  subject { field }

  it { should respond_to :name }
  it { should respond_to :street_address }
  it { should respond_to :city }
  it { should respond_to :zip_code }
  it { should respond_to :notes }

  it { should be_valid }

  describe 'associated fieldslots' do
    before { 2.times { FactoryGirl.create(:fieldslot, field: field) } }
    it "should be destroyed when field is destroyed" do
      fieldslots = field.fieldslots.dup
      field.destroy
      fieldslots.should_not be_empty
      fieldslots.each do |fieldslot|
        Fieldslot.find_by_id(fieldslot.id).should be_nil
      end
    end
  end

  describe 'availabilities that associate with only one field' do
    let(:availability) { FactoryGirl.create(:availability) }
    before { availability.fields = [field] }
    
    it "should be destroyed when field is destroyed" do
      availability.fields.count.should == 1
      availabilities = field.availabilities.dup
      field.destroy
      availabilities.should_not be_empty
      availabilities.each do |a|
        Availability.find_by_id(a.id).should be_nil
      end
    end
  end
end
