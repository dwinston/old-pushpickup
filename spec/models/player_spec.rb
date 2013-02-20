# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Player do
  before { @player = Player.new(name: 'Donny Winston', 
                                email: 'donny@winston.com',
                                password: 'foobar',
                                password_confirmation: 'foobar') }

  subject { @player }

  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :password_digest }
  it { should respond_to :password }
  it { should respond_to :password_confirmation }
  it { should respond_to :remember_token }
  it { should respond_to :admin }
  it { should respond_to :authenticate }

  it { should be_valid }
  it { should_not be_admin }

  describe 'accessible attributes' do
    it 'should not allow access to admin' do
      expect do
        Player.new(admin: @player.admin)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      @player.save!
      @player.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @player.name = ' ' }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @player.email = ' ' }
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { @player.password = @player.password_confirmation = ' ' }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @player.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @player.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @player.name = 'a' * 51}
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @player.email = invalid_address
        @player.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @player.email = valid_address
        @player.should be_valid
      end
    end
  end
  
  describe "email address with mixed case" do
    let(:mixed_case_email) { 'Foo@ExAMPLe.CoM' }

    it "should be saved as all lower-case" do
      @player.email = mixed_case_email
      @player.save
      @player.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when email address is already taken" do
    before do
      player_with_same_email = @player.dup
      player_with_same_email.email = @player.email.upcase
      player_with_same_email.save
    end
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @player.password = @player.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @player.save }
    let(:found_player) { Player.find_by_email(@player.email) }

    describe "with valid password" do
      it { should == found_player.authenticate(@player.password) }
    end

    describe "with invalid password" do
      let(:player_for_invalid_password) { found_player.authenticate('invalid') }

      it { should_not == player_for_invalid_password }
      specify { player_for_invalid_password.should be_false }
    end
  end

  describe 'remember token' do
    before { @player.save }
    its(:remember_token) { should_not be_blank }
  end
end
