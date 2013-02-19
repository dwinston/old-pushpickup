include ApplicationHelper

def valid_signin(player)
  fill_in 'Email',    with: player.email
  fill_in 'Password', with: player.password
  click_button 'Sign in'
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector 'div.alert.alert-error', text: message
  end
end
