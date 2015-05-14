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
    title = enquiry_title_fields(enquiry)
    return enquiry.short_id if title.empty?
    "#{title} (#{enquiry.short_id})".strip
  end

  def enquiry_title_fields(enquiry)
    title_fields = Form.find_by_name(Enquiry::FORM_NAME).title_fields
    title_fields.map { |f| enquiry.send(f.name) } .compact.join(' ')
  end

  def enquiries_enabled
    Enquiry.enquiries_enabled
  end
end
