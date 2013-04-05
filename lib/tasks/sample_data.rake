namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    # make an admin player
    admin = Player.create!(name: 'Donny Winston',
                           email: 'dwinston@alum.mit.edu',
                           password: 'foobar',
                           password_confirmation: 'foobar')
    admin.toggle!(:admin)
    admin.toggle!(:activated)

    # make players
    20.times do |n|
      name = Faker::Name.name
      email = "dwinst+#{n+1}@gmail.com"
      password = 'password'
      player = Player.create!(name: name,
                              email: email,
                              password: password,
                              password_confirmation: password)
      player.toggle!(:activated)
    end

    # make cities and fields
    5.times do
      city = Faker::Address.city
      state_abbr = Faker::Address.state_abbr 
      City.create!(name: "#{city}, #{state_abbr}")
    end
    cities = City.all(limit: 5)
    5.times do
      cities.each do |city|
        name = Faker::Name.last_name + ' Park'
        street_address = Faker::Address.street_address 
        zip_code = Faker::Address.zip_code 
        notes = Faker::Lorem.paragraphs.join("\n")
        city.fields.create!(name: name, street_address: street_address, 
                            zip_code: zip_code, notes: notes)
      end
    end

   some_players = Player.all(limit: 14)

    # make availabilities
    10.times do
      start_time = rand(13.days).since(2.hours.from_now).beginning_of_hour
      duration = [45, 60, 75, 90, 105, 120].sample
      some_players.each do |player| 
        availability = player.availabilities.build(start_time: start_time, duration: duration)
        availability.fields << Field.all.sample
        availability.save!
      end
      
      # ensure some games
      start_time = rand(13.days).since(2.hours.from_now).beginning_of_hour
      duration = [45, 60, 75, 90, 105, 120].sample
      field = Field.all.sample
      some_players.each do |player|
        availability = player.availabilities.build(start_time: start_time, duration: duration)
        availability.fields << field
        availability.save!
      end
    end
  end
end
