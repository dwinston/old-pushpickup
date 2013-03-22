module Needs
  extend ActiveSupport::Concern

  included do
    has_many :needs
    @@needs = {}
  end

  module ClassMethods
    def need(name, default)
      needs = self.class_variable_get(:@@needs)
      needs[name] = default
      self.class_variable_set(:@@needs, needs)
    end
  end

  # Persists current default value of need to db for self so that self is not
  # caught off guard by changes to defaults
  def get_need(name)
    self.needs.find_by_name(name)  ||
      (@@needs.has_key?(name) && self.needs.create!(name: name, value: @@needs[name])) ||
      nil
  end

  def set_need(name, value)
    n = self.needs.find_or_create_by_name(name)
    n.update_attribute(:value, value)
  end

  def method_missing(method, *args)
    if @@needs.keys.any?{|k| method =~ /\A#{k}=?\z/}
      if method =~ /=/
        self.set_need(method.to_s.gsub('=', ''), *args)
      else
        self.get_need(method)
      end
    else
      super
    end
  end
end
