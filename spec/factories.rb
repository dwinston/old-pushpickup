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

  factory :city do
    name Faker::Address.city + ', ' +  Faker::Address.state_abbr
  end

  factory :field do
    name Faker::Name.last_name + ' Park'
    street_address Faker::Address.street_address 
    zip_code Faker::Address.zip_code 
    notes Faker::Lorem.paragraphs.join("\n")
    city
  end
end
