# == Schema Information
#
# Table name: players
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  email                      :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  password_digest            :string(255)
#  remember_token             :string(255)
#  admin                      :boolean          default(FALSE)
#  password_reset_token       :string(255)
#  password_reset_sent_at     :datetime
#  activated                  :boolean          default(FALSE)
#  email_confirmation_token   :string(255)
#  email_confirmation_sent_at :datetime
#  subscribed                 :boolean          default(FALSE)
#

require 'spec_helper'

describe Player do
  let(:player) { FactoryGirl.create(:player) }
  subject { player }

  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :password_digest }
  it { should respond_to :password }
  it { should respond_to :password_confirmation }
  it { should respond_to :remember_token }
  it { should respond_to :admin }
  it { should respond_to :authenticate }
  it { should respond_to :availabilities }
  it { should respond_to :games }
  it { should respond_to :needs }

  it { should be_valid }
  it { should_not be_admin }

  describe 'accessible attributes' do
    it 'should not allow access to admin' do
      expect do
        Player.new(admin: player.admin)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      player.save!
      player.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { player.name = ' ' }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { player.email = ' ' }
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { player.password = player.password_confirmation = ' ' }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { player.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { player.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { player.name = 'a' * 51}
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        player.email = invalid_address
        player.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        player.email = valid_address
        player.should be_valid
      end
    end
  end
  
  describe "email address with mixed case" do
    let(:mixed_case_email) { 'Foo@ExAMPLe.CoM' }

    it "should be saved as all lower-case" do
      player.email = mixed_case_email
      player.save
      player.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when email address is already taken" do
    let(:another_player) { FactoryGirl.create(:player) }
    before do
      # player_with_same_email = player.dup
      # player_with_same_email.email = player.email.upcase
      # player_with_same_email.save
      player.email = another_player.email.upcase
      player.save
    end
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { player.password = player.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { player.save }
    let(:found_player) { Player.find_by_email(player.email) }

    describe "with valid password" do
      it { should == found_player.authenticate(player.password) }
    end

    describe "with invalid password" do
      let(:player_for_invalid_password) { found_player.authenticate('invalid') }

      it { should_not == player_for_invalid_password }
      specify { player_for_invalid_password.should be_false }
    end
  end

  describe 'remember token' do
    before { player.save }
    its(:remember_token) { should_not be_blank }
  end

  describe 'availability associations' do
    before { player.save }
    let(:now) { DateTime.now }
    let!(:later_availability) do
      FactoryGirl.create(:availability, player: player, 
                         start_time: now.advance(days: 5).beginning_of_hour)
    end
    let!(:sooner_availability) do
      FactoryGirl.create(:availability, player: player, 
                         start_time: now.advance(hours: 5).beginning_of_hour)
    end

    it 'should have the right availabilities in the right order' do
      player.availabilities.should == 
        [sooner_availability, later_availability]
    end

    it "should destroy associated availabilities" do
      availabilities = player.availabilities.dup
      player.destroy
      availabilities.should_not be_empty
      availabilities.each do |availability|
        Availability.find_by_id(availability.id).should be_nil
      end
    end

    describe 'status' do
      let(:unfollowed_availability) do
        FactoryGirl.create(:availability, player: FactoryGirl.create(:player))
      end

      its(:availability_feed) { should include sooner_availability }
      its(:availability_feed) { should include later_availability }
      its(:availability_feed) { should_not include unfollowed_availability }
    end
  end

  describe 'games' do
    let(:field) { FactoryGirl.create(:field) }
    let(:start_time) { DateTime.now.advance(days: 2).beginning_of_hour }

    describe 'with enough overlapping availabilities' do
      before do
        13.times { FactoryGirl.create(:availability, start_time: start_time, duration: 60, fields: [field]) }
      end

      it 'adding another availability should create a game' do
        expect do
          FactoryGirl.create(:availability, start_time: start_time, duration: 120, player: player, fields: [field]) 
        end.to change(Game, :count).by(1)
      end

      describe 'and with enough additional overlapping availabiliies such that two nonoverlapping games are possible' do
        before do
            13.times { FactoryGirl.create(:availability, start_time: start_time.advance(minutes: 60), duration: 60, 
                                          fields: [field]) }
        end
        
        describe "if the player is okay with two games on the same day" do
          before do
            player.min_days_separating_games = 0
            player.save!
          end
        
          it 'adding another availability that overlaps with all should create two games' do
            expect do
              FactoryGirl.create(:availability, start_time: start_time, duration: 120, player: player, fields: [field]) 
            end.to change(Game, :count).by(2)
          end
        end

        describe "if the player's needs include at most one game per day" do
          before do
            player.min_days_separating_games = 1
            player.save!
          end

          it 'adding another availability that overlaps with all should create only one game' do
            expect do
              FactoryGirl.create(:availability, start_time: start_time, duration: 120, player: player, fields: [field]) 
            end.to change(Game, :count).by(1)
          end
        end
      end
    end
  end

  describe "#send_password_reset" do
    it "generates a unique password_reset token each time" do
      player.send_password_reset
      last_token = player.password_reset_token
      player.send_password_reset
      player.password_reset_token.should_not eq(last_token)
    end

    it "saves the time the password reset was sent" do
      player.send_password_reset
      player.reload.password_reset_sent_at.should be_present
    end

    it "delivers email to player" do
      player.send_password_reset
      last_email.to.should include(player.email)
    end
  end
end
