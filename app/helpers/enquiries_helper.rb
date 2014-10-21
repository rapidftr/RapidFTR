module EnquiriesHelper
  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  ORDER_BY = {'active' => 'created_at', 'all' => 'created_at'}

  def number_of_enquiries_with_matches
    Enquiry.all.all.select { |enquiry| enquiry.potential_matches.size > 0 }.size
  end

  def enquiry_title(enquiry)
    title_field = Form.find_by_name(Enquiry::FORM_NAME).title_field
    enquiry_title = title_field.nil? ? '' : enquiry.send(title_field.name)
    "#{enquiry_title} (#{enquiry.short_id})".strip
  end
end
