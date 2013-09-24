Given /^the following enquiries exist in the system:$/ do |enquiry_table|
  enquiry_table.hashes.each do |enquiry_hash|
    enquiry_hash.update(:criteria => {"name" => "sample_name", "location" => "sample_location"})
  end

  begin
    Enquiry.create!(enquiry_table.hashes.first)
  rescue
    raise
  end
end