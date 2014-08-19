Given /^the following enquiries exist in the system:$/ do |enquiry_table|
  enquiry_table.hashes.each do |enquiry_hash|
    create_enquiry(enquiry_hash)
  end
end

private

def enquiry_defaults
  {
    'created_by' => 'Billy',
    'created_organisation' => 'UNICEF'
  }
end

def create_enquiry(enquiry_hash)
  enquiry_hash.reverse_merge!(enquiry_defaults)

  user_name = enquiry_hash['created_by']
  user = data_populator.ensure_user_exists(user_name)

  enquiry = Enquiry.new_with_user_name(user, enquiry_hash)
  enquiry.create!
end
