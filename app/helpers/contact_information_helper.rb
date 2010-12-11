module ContactInformationHelper
  def show_contact_field field
    value = @contact_information[field]
    return "<p id='contact_info_#{field}'>#{value}</p>"
    
  end
end