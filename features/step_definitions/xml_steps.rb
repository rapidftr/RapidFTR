Then /^I should see a superset of the following xml$/ do |xml|
  xml.should be_xml_subset_of(response_body)
end

