namespace :db do
  desc 'Fill database with fields beyond the initial ones of init_data rake task'
  task populate_with_fields: :environment do

    fields = [
      {:name=>"Maxwell Family Field", :street_address=>"2205 Piedmont Ave", :city_name=>"Berkeley, CA", :zip_code=>"94720", :notes=>""}, 
      {:name=>"Bushrod Park", :street_address=>"6051 Racine St", :city_name=>"Oakland, CA", :zip_code=>"94609", :notes=>""}, 
      {:name=>"Cubberly Field", :street_address=>"4100 Middlefield Rd", :city_name=>"Palo Alto, CA", :zip_code=>"94306", :notes=>"Enter Cubberley Community Center's south(east) entrance, directly opposite Montrose Avenue, and proceed all the way to the back."}, 
      {:name=>"Tom Bates Regional Sports Complex", :street_address=>"400-408 Gilman Street", :city_name=>"Berkeley, CA", :zip_code=>"94710", :notes=>"Also known as the Gilman Fields."}, 
      {:name=>"San Pablo Park", :street_address=>"San Pablo Park", :city_name=>"Berkeley, CA", :zip_code=>"94702", :notes=>""}, 
      {:name=>"Grove Park", :street_address=>"1730 Oregon Street", :city_name=>"Berkeley, CA", :zip_code=>"94703", :notes=>""}, 
      {:name=>"Mitchell Park", :street_address=>"Mitchell Park", :city_name=>"Palo Alto, CA", :zip_code=>"94307", :notes=>""}
    ]

    fields.each do |field|
      city = City.find_or_create_by_name!(field[:city_name])
      city.fields.create!(name: field[:name], street_address: field[:street_address],
                          zip_code: field[:zip_code], notes: field[:notes]) unless Field.find_by_name_and_zip_code(field[:name], field[:zip_code])
    end
  end
end
