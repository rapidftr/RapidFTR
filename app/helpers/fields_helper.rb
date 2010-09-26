module FieldsHelper
  
	def option_fields_for form, suggested_field
		return "" unless suggested_field.field.option_strings
		suggested_field.field.option_strings.collect do |option_string|
	  		form.hidden_field "option_strings][", { :id => "option_string_" + option_string, :value => option_string }
		end
    end

	def display_options field
		field.option_strings.collect { |f| '"'+f+'"' }.join(", ")
	end
end
