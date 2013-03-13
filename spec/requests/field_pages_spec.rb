require 'spec_helper'

describe "Field Pages" do

  subject { page }
  let(:player) { FactoryGirl.create(:player) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:city) { FactoryGirl.create(:city) }
  let!(:field) { FactoryGirl.create(:field, city: city) }
  before do 
    sign_in admin
  end

  describe 'field creation' do

    describe 'with valid information' do

      before { fill_in_field_form FactoryGirl.build(:field) }

      it 'should create a new field' do
        expect { click_button 'Submit' }.to change(Field, :count).by(1)
      end
    end

    describe 'with invalid information' do
      before { visit new_field_path }

      it 'should not create an availability' do
        expect { click_button 'Submit' }.not_to change(Field, :count)
      end

      describe 'error messages' do
        before { click_button 'Submit' }
        it { should have_content 'error' }
      end
    end
  end

  describe 'index' do
    before do 
      visit fields_path
    end

    describe 'as non-admin' do
      let(:player) { FactoryGirl.create :player }
      before do
        sign_in player
        visit fields_path
      end

      it { should_not have_link 'Add field', href: new_field_path }

      describe 'having entered a start time and duration' do
        before do
          visit root_path
          fill_in 'Start time', with: 'tomorrow 3pm'
          fill_in 'Duration', with: '2 hours'
        end

        describe 'and decided to add fields' do
          before { click_button 'Add fields'}

          describe 'without fields selected' do
            
            it 'should not create a new availability' do
              expect { click_button 'Choose field(s)' }.to_not change(Availability, :count).by(1)
            end
          end

          describe 'with fields selected' do
            before do
              select city.name, from: :city_id
              click_button 'Find'
            end

            it 'should create a new availability' do
              expect do
                check field.name
                click_button 'Choose field(s)'
              end.to change(Availability, :count).by(1)
            end
          end
        end
      end
    end
      

    it { should have_selector 'title', text: 'Find fields' }
    it { should have_link 'Add field', href: new_field_path }
    it { should have_content field.name }

    describe 'after a search' do
      before do
        select city.name, from: :city_id
        click_button 'Find'
      end

      it { should have_content field.name }
      it { should have_link 'delete', href: field_path(field) }
      it { should have_link 'edit', href: edit_field_path(field) }
      it { should have_link 'map', href: google_maps_link(field) }

      it 'can delete a field' do
        expect { click_link 'delete' }.to change(Field, :count).by(-1)
      end

      describe 'editing a field' do
        let(:new_field_name) { Faker::Name.last_name + ' Hill' }
        before do 
          visit edit_field_path(field)
          fill_in 'Name', with: new_field_name 
          click_button 'Submit'
        end

        it { should have_content new_field_name }
      end
    end
  end
end
