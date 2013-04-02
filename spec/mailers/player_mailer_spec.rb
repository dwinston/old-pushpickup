require "spec_helper"

describe PlayerMailer do
  describe "signup_confirmation" do
    let(:mail) { PlayerMailer.signup_confirmation }

    it "renders the headers" do
      mail.subject.should eq("Signup confirmation")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
