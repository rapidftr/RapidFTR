module PropertiesLocalization

  module ClassMethods
    def localize_properties(properties)
      RapidFTR::Application.locales.each do |locale|
        properties.each { |key| property "#{key}_#{locale}" }
      end

      properties.each do |method|
        define_method method do |*args|
          locale = args.first || I18n.locale
          locale_field_value = send("#{method}_#{locale}")
          if locale_field_value.nil? || locale_field_value.empty?
            send "#{method}_#{I18n.default_locale}"
          else
            locale_field_value
          end
        end

        define_method "#{method}=" do |value|
          send "#{method}_#{I18n.default_locale}=", value
        end

        define_method "#{method}_all=" do |value|
          RapidFTR::Application.locales.each do |locale|
            send "#{method}_#{locale}=", value
          end
        end
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def formatted_hash
    properties_hash = {}
    properties.map(&:name).each do |property|
      locale = property[-2..-1]
      property_name = property[0..property.length - 4]
      property_value = get_property_value(property)
      property_value.collect! { |value| value.formatted_hash } if property_value.is_a?(CouchRest::Model::CastedArray)
      property_value.map! { |value| value.is_a?(String) ? value.gsub(/\r\n?/, "\n").rstrip : value } if property_value.is_a?(Array)
      property_value = property_value.gsub(/\r\n?/, "\n").rstrip if property_value.is_a?(String)

      next if property_value.nil?
      if RapidFTR::Application.locales.include? locale.to_s
        properties_hash[property_name] = properties_hash[property_name].nil? ? {locale => property_value} : properties_hash[property_name].merge!({locale => property_value})
      else
        properties_hash[property] = property_value
      end
    end
    properties_hash
  end

  def get_property_value(property)
    value = send(property)
    property.include?("option_strings_text") ? value.split("\n") : value if value
  end

end
