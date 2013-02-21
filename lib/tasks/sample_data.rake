namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    admin = Player.create!(name: 'Donny Winston',
                           email: 'dwinston@alum.mit.edu',
                           password: 'foobar',
                           password_confirmation: 'foobar')
    admin.toggle!(:admin)

    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = 'password'
      Player.create!(name: name,
                     email: email,
                     password: password,
                     password_confirmation: password)
    end

    players = Player.all(limit: 6)
    50.times do
      start_time = rand(13.days).since(2.hours.from_now).beginning_of_hour
      duration = [45, 60, 75, 90, 105, 120].sample
      players.each do |player| 
        player.availabilities.create!(start_time: start_time, duration: duration)
      end
    end
  end
end
