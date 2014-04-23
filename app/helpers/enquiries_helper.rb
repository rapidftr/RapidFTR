module EnquiriesHelper

  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  def text_to_identify_enquiry enquiry
    enquiry['enquirer_name'].blank? ? enquiry.id : "Enquiry by #{enquiry['enquirer_name']}: #{enquiry.id}"
  end
end
