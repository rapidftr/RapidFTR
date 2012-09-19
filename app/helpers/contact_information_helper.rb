module ContactInformationHelper
  def show_contact_field field
    value = @contact_information[field]
    return raw "<p id='contact_info_#{field}'><strong>#{field.to_s.capitalize.humanize}:</strong> #{value}</p>"
  end
end