module HighlightFieldsHelper
  def enquiry_sorted_highlighted_fields
    Form.find_by_name(Enquiry::FORM_NAME).sorted_highlighted_fields
  end
end
