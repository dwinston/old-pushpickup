FactoryGirl.define do
  factory :player do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobar'
    password_confirmation 'foobar'

    factory :admin do
      admin true
    end
  end

  factory :availability do
    start_time { DateTime.now.advance(days: 5).beginning_of_hour }
    duration 120
    player
  end

  factory :field do
    name Faker::Name.last_name + ' Park'
    street_address Faker::Address.street_address 
    city Faker::Address.city 
    state_abbr Faker::Address.state_abbr 
    zip_code Faker::Address.zip_code 
    notes Faker::Lorem.paragraphs.join("\n")
  end
end
