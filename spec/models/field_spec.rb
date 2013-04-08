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
#  latitude       :float
#  longitude      :float
#  gmaps          :boolean
#

require 'spec_helper'

describe Field do

  let(:start_time) { DateTime.now.advance(days: 5).beginning_of_hour }
  let(:field) { FactoryGirl.create(:field) }

  subject { field }

  it { should respond_to :name }
  it { should respond_to :street_address }
  it { should respond_to :city }
  it { should respond_to :zip_code }
  it { should respond_to :notes }
  it { should respond_to :games }

  it { should be_valid }

  describe 'associated fieldslots' do
    before do
      2.times { FactoryGirl.create(:fieldslot, field: field) }
    end

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

  describe 'with 13 overlapping availabilities' do
    before do
      13.times do 
        FactoryGirl.create(:availability, start_time: start_time, duration: 120, fields: [field])
      end
    end

    describe 'adding a 14th availability to the field' do
      let(:player) { FactoryGirl.create(:player) }

      describe 'that overlaps fully' do
        before { FactoryGirl.create(:availability, player: player,
                                    start_time: start_time, duration: 120, fields: [field]) }
        its("availabilities.count") { should == 14}
        its("games.count") { should == 1 }
        its("games.first.duration") { should == player.min_duration_of_game.value }

        context 'with a game on' do
          it 'one more availability does not create a new game' do
            expect { FactoryGirl.create(:availability, start_time: start_time, duration: 120, fields: [field]) }.
              not_to change(Game, :count)
          end
          it 'one more availability results in its player joining the game' do
            expect { FactoryGirl.create(:availability, start_time: start_time, duration: 120, fields: [field]) }.
              to change(field.games.first.players, :count).by(1)
          end
        end
      end

      describe 'that partially overlaps' do
        before { FactoryGirl.create(:availability, player: player,
                                    start_time: start_time.advance(minutes: 60), duration: 120, fields: [field]) }
        its("availabilities.count") { should == 14}
        its("games.count") { should == 1 }
        its("games.first.duration") { should == player.min_duration_of_game.value }
      end

      describe 'that does not overlap (sufficiently)' do
        before { FactoryGirl.create(:availability, player: player,
                                    start_time: start_time.advance(minutes: 90), duration: 120, fields: [field]) }
        its("availabilities.count") { should == 14}
        its("games.count") { should == 0 }
      end
    end
  end
end
