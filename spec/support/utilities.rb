include ApplicationHelper
include FieldsHelper

def sign_up(player)
  visit signup_path
  fill_in 'Name',             with: player.name
  fill_in 'Email',            with: player.email
  fill_in 'Password',         with: player.password
  fill_in 'Confirm password', with: player.password
  click_button 'Create'
  # Sign in when not using Capybara as well.
  # cookies[:remember_token] = player.reload.remember_token
end

def sign_in(player)
  visit signin_path
  fill_in 'Email',    with: player.email
  fill_in 'Password', with: player.password
  click_button 'Sign in'
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = player.remember_token
end

# signs in when already at signin_path
def and_sign_in(player)
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

def submit_availability(fields, starts_at = {})
  day, time, duration = starts_at[:day], starts_at[:time], starts_at[:duration]
  select day if day
  select time.lstrip if time # due to Time::DATE_FORMATS[:ampm_time] = "%l:%M%P"
  select duration if duration
  fields.each do |field| 
    check field.name
  end
  click_button 'Post'
end

def submit_unavailability(fields, why_not_open, starts_at = {})
  check 'Unavailability?'
  fill_in 'Why?', with: why_not_open
  submit_availability(fields, starts_at)
end


RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector 'div.alert.alert-error', text: message
  end
end

def last_email
  ActionMailer::Base.deliveries.last
end

def reset_email
  ActionMailer::Base.deliveries = []
end
