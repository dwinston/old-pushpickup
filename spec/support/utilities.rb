include ApplicationHelper

def sign_in(player)
  visit signin_path
  fill_in 'Email',    with: player.email
  fill_in 'Password', with: player.password
  click_button 'Sign in'
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = player.remember_token
end

def submit_field(field)
  visit new_field_path
  fill_in 'Name', with: field.name
  fill_in 'Street address', with: field.street_address
  fill_in 'City', with: field.city
  fill_in 'State', with: field.state_abbr
  fill_in 'Zip', with: field.zip_code
  fill_in 'Notes', with: field.notes
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector 'div.alert.alert-error', text: message
  end
end
