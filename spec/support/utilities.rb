include ApplicationHelper
include FieldsHelper

def sign_in(player)
  visit signin_path
  fill_in 'Email',    with: player.email
  fill_in 'Password', with: player.password
  click_button 'Sign in'
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = player.remember_token
end

def fill_in_field_form(field)
  visit new_field_path
  fill_in 'Name', with: field.name
  fill_in 'Street address', with: field.street_address
  select field.city.name, from: 'City'
  fill_in 'Zip', with: field.zip_code
  fill_in 'Notes', with: field.notes
end

def submit_availability(availability, fields)
  visit root_path
  fill_in 'Start time', with: availability.start_time.to_s
  fill_in 'Duration', with: availability.duration.to_s
  fields.each do |field| 
    check field.name
  end
  click_button 'Post'
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector 'div.alert.alert-error', text: message
  end
end
