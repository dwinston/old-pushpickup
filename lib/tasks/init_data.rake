namespace :db do
  desc 'Fill database with initial data'
  task populate: :environment do
    # make an admin player
    admin = Player.create!(name: 'Donny Winston',
                           email: 'dwinston@alum.mit.edu',
                           password: 'foobar',
                           password_confirmation: 'foobar')
    admin.toggle!(:admin)
    admin.toggle!(:activated)

    # initialize real cities and fields
    examples = Field.examples_for_testing
    examples.each do |example|
      city = City.find_or_create_by_name!(example[:city_name])
      city.fields.create!(name: example[:name], street_address: example[:street_address],
                          zip_code: example[:zip_code], notes: example[:notes])
    end
  end
end
