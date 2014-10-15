Form.new(:name => Child::FORM_NAME).save if Form.find_by_name(Child::FORM_NAME).nil?
Form.new(:name => Enquiry::FORM_NAME).save if Form.find_by_name(Enquiry::FORM_NAME).nil?
