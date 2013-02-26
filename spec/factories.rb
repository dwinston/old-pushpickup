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
    name 'Cubberly'
    full_address '4000 Middlefield Road, Palo Alto, CA 94303'
    city 'Palo Alto, CA'
    notes "Enter Cubberley Community Center's south entrance, directly opposite Montrose Avenue, and proceed all the way to the back."
  end
end
