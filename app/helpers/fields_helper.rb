module FieldsHelper
	def option_fields_for form, suggested_field
		return "" unless suggested_field.field.option_strings
		suggested_field.field.option_strings.collect do |option_string|
	  		form.text_field "option_strings][", { :id => "option_strings", :value => option_string }
		end
	end
	def display_options field
		["<ul>", field.option_strings.map {|option| "<li>#{option}</li>"}, "</ul>"]
	end
end
