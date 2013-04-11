require 'spec_helper'

describe "Field Pages" do

  subject { page }
  let(:player) { FactoryGirl.create(:player) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:field) { FactoryGirl.create(:field, sample: Field.examples_for_testing[0]) }
  let(:another_field) { FactoryGirl.create(:field, sample: Field.examples_for_testing[1]) }

  describe 'field creation as admin' do
    before { sign_in admin }

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

  describe 'show' do
    before { visit field_path(field) }

    it { should have_selector 'title', text: field.name }
    it { should have_content field.name }
    
    describe 'with an upcoming game' do
      let(:soon) { Time.zone.now.beginning_of_hour + 2.hours }
      before do
        14.times do
          FactoryGirl.create(:availability, start_time: soon, fields: [field])
        end
        visit field_path(field)
      end

      it { should have_content "GAME ON"} 
      it { should have_content soon.to_s(:weekday_and_ordinal)} 
    end

    describe 'with an upcoming closed fieldslot (unavailability)' do
      let(:why_not_open) { "Zombie invasion" }
      before do
        sign_in admin
        visit field_path(field)
        check field.name
        check 'Unavailability?'
        fill_in 'Why?', with: why_not_open
        click_button 'Post'
        visit field_path(field)
      end

      it { should have_content why_not_open }

      describe 'and anyone viewing the field page' do
        before do
          delete signout_path # sign out signed-in player
          visit field_path(field)
        end

        it { should have_content why_not_open }
      end
    end

    it { should have_content 'Add an availability' }

    context 'while not logged in' do

      describe 'and submitting an availability' do
        before { submit_availability [field] }

        it { should have_content 'Sign in' }

        describe 'and after logging in' do
          before { and_sign_in player }

          it { should have_selector 'title', text: full_title('') }
        end
      end

      describe 'and adding a field' do
        before { click_button 'Add field' }

        it { should have_content 'Sign in' }

        describe 'and after logging in' do
          before { and_sign_in player }

          it { should have_selector 'title', text: full_title('') }
        end
      end
    end

    context 'while logged in' do
      before do
        sign_in player
        visit field_path(another_field) 
        visit field_path(field) 
      end

      describe 'and submitting a valid availability' do
        before { submit_availability [field] }

        it { should have_content 'Availability created' }
      end

      describe 'and submitting an invalid availability' do
        before { submit_availability [] }

        it { should have_content 'error' }
      end

      describe 'and adding a field' do

        context 'without checking a field' do
          before { click_button 'Add field' }

          it { should have_selector 'title', text: full_title('Fields') }

          describe 'clicking on another field' do
            before { click_link another_field.name }

            it { should have_content another_field.name }
            it { should_not have_content field.name }
          end
        end

        describe 'checking the field' do
          before do
            check field.name
            click_button 'Add field'
          end

          it { should have_selector 'title', text: full_title('Fields') }

          describe 'clicking on another field' do
            before { click_link another_field.name }

            it { should have_content another_field.name }
            it { should have_content field.name }

            describe 'and submitting a valid availability' do
              before { submit_availability [field, another_field] }

              it { should have_content 'Availability created' }
            end
          end
        end
      end
    end
  end

  describe 'index' do
    before do
      visit field_path(field) # creates field via let(:field) above
      visit fields_path
    end

    it { should have_selector 'title', text: 'Fields' }
    it { should have_content field.name }
    it { should_not have_link 'Add field', href: new_field_path }

    describe 'as non-admin' do
      before do
        sign_in player
        visit fields_path
      end

      it { should_not have_link 'Add field', href: new_field_path }
    end

    describe 'as admin' do
      before do
        sign_in admin
        visit fields_path
      end

      it { should have_link 'Add field', href: new_field_path }
    end
      
    # I spent an inordinate amount of time getting this to pass. I still do not understand why using 'field' rather
    # than 'Field.first' cannot be made to work. I do not understand why created fields do not appear to be deleted
    # from the test database after each example.
    describe 'after a search' do
      before do
        check Field.first.city.name
        click_button 'Refine'
      end

      it { should have_content Field.first.name }
    end

    describe 'as admin' do
      before do
        sign_in admin
        visit fields_path
      end

      it { should have_link 'delete', href: field_path(field) }
      it { should have_link 'edit', href: edit_field_path(field) }

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
