FactoryGirl.define do
  factory :player do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobar'
    password_confirmation 'foobar'
    activated true

    factory :admin do
      admin true
    end
  end

  factory :city do
    name Field.examples_for_testing.sample[:city_name]
    
    factory :fake_city do
      name Faker::Address.city + ', ' +  Faker::Address.state_abbr
    end
  end

  factory :field do
    name Faker::Name.last_name + ' Park'
    street_address Faker::Address.street_address 
    zip_code Faker::Address.zip_code 
    notes Faker::Lorem.paragraphs.join("\n")
    city FactoryGirl.create(:fake_city)

    ignore do
      sample Field.examples_for_testing.sample
    end

    before(:create) do |field, evaluator|
      field.name = evaluator.sample[:name]
      field.street_address = evaluator.sample[:street_address]
      field.zip_code = evaluator.sample[:zip_code]
      field.notes = evaluator.sample[:notes]
      field.city = FactoryGirl.create(:city, name: evaluator.sample[:city_name])
    end

    factory :fake_field do
      name Faker::Name.last_name + ' Park'
      street_address Faker::Address.street_address 
      zip_code Faker::Address.zip_code 
      notes Faker::Lorem.paragraphs.join("\n")
      city fake_city
    end
  end

  factory :availability do
    start_time { Time.zone.now.beginning_of_hour + 5.days }
    duration 120
    player

    ignore do
      fields FactoryGirl.create_list(:field, 1)
    end

    before(:create) do |availability, evaluator|
      availability.fields = evaluator.fields
    end

    factory :unavailability do
      ignore do
        why_not_open 'Zombie apocalypse'
      end

      after(:create) do |unavailability, evaluator|
        unavailability.fieldslots.each do |fs| 
          fs.update_attributes!(open: false, why_not_open: evaluator.why_not_open)
        end
      end
    end
  end

  factory :fieldslot do
    availability
    field

    factory :closed_fieldslot do
      open false
      why_not_open 'Zombie apocalypse'
    end
  end
end
