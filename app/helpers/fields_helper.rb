module FieldsHelper

  def wrap(notes)
    sanitize(raw(notes.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end

  def wrap_long_string(text, max_width = 30)
    zero_width_space = "&#8203;"
    regex = /.{1,#{max_width}}/
    (text.length < max_width) ? text :
                                text.scan(regex).join(zero_width_space)
  end

  def google_maps_link(field)
    "http://maps.google.com/maps?q=" + 
      "#{field.street_address}, #{field.city.name} #{field.zip_code}".gsub(/\s+/, '+')
  end
end
