module PropertiesLocalization

  def self.included klass
    @klass = klass
  end

  def self.localize_properties(properties)
    RapidFTR::Application::LOCALES.each do |locale|
      properties.each { |key| @klass.property "#{key}_#{locale}" }
    end

    properties.each do |method|
      define_method method do |*args|
        locale = args.first || I18n.locale
        if self.send("#{method}_#{locale}").nil?  || self.send("#{method}_#{locale}").empty?
          self.send("#{method}_#{I18n.default_locale}")
          end
      end

      define_method "#{method}=" do |value|
        self.send("#{method}_#{I18n.default_locale}=", value)
      end
    end
  end

  def formatted_hash
    properties_hash = {}
    self.properties.map(&:name).each do |property|
      locale = property[-2..-1]
      property_name = property[0..property.length-4]
      property_value = self.get_property_value(property)
      property_value.collect! { |value| value.formatted_hash } if property_value.class == CastedArray
      next if property_value.nil?
      if RapidFTR::Application::LOCALES.include? locale.to_s
        properties_hash[property_name] = properties_hash[property_name].nil? ? {locale => property_value} : properties_hash[property_name].merge!({locale => property_value})
      else
        properties_hash[property] = property_value
      end
    end
    properties_hash
  end

  def get_property_value(property)
    value = self.send(property)
    property.include?("option_strings_text") ? value.split("\n") : value if value
  end

end
