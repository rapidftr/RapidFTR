module ContactInformationHelper
  def show_contact_field field
    value = @contact_information[field]
    return raw "<p id='contact_info_#{field}'><strong>#{t("contact.field."+field.to_s)}:</strong> #{value}</p>"
  end
end