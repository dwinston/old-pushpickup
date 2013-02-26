require 'spec_helper'

describe Field do

  let(:field) { FactoryGirl.create(:field) }

  subject { field }

  it { should respond_to :name }
  it { should respond_to :full_address }
  it { should respond_to :city }
  it { should respond_to :notes }

  it { should be_valid }

  describe 'city' do

    describe 'with valid information' do
      its(:city) { should == field.full_address.scan(field.city).shift }
    end

    describe 'with invalid information' do
      before { field.city = 'Zion, XC' }
      it { should_not be_valid }
    end
  end


end
