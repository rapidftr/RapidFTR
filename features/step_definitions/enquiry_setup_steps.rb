Given /^the following enquiries exist in the system:$/ do |enquiry_table|
  enquiry_table.hashes.each do |enquiry_hash|
    create_enquiry(enquiry_hash)
  end
end

When /^I mark child with unique_id "([^\"]*)" as not matching$/ do |unique_id|
  find_by_id("mark_#{unique_id}").click
end

Then /^I should see "([^\"]*)" enquiries on the page$/ do |number_of_records|
  enquiry_list_page.should_be_showing(number_of_records.to_i)
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

def enquiry_list_page
  @_enquiry_list_page ||= EntityListPage.new(Capybara.current_session)
end
