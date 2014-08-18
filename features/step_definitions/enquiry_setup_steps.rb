Given /^the following enquiries exist in the system:$/ do |enquiry_table|
  enquiry_table.hashes.each do |enquiry_hash|
    enquiry_hash.update(:criteria => {'name' => 'sample_name', 'location' => 'sample_location'})

    begin
      Enquiry.create!(enquiry_hash)
    rescue
      raise
    end
  end
end
