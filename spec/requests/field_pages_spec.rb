require 'spec_helper'

describe "FieldPages" do

  subject { page }
  let(:player) { FactoryGirl.create(:player) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe 'field creation' do

    describe 'with valid information' do

      before { submit_field FactoryGirl.build(:field) }

      it 'should create a new field' do
        expect { click_button 'Submit' }.to change(Field, :count).by(1)
      end
    end

    describe 'with invalid information' do

      it 'should not create an availability' do
        expect { click_button 'Submit' }.not_to change(Field, :count)
      end

      describe 'error messages' do
        before { click_button 'Submit' }
        it { should have_content 'error' }
      end
    end
    
  end
end
