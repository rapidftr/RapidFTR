Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |link, section_name|
  row = Hpricot(response.body).search("tr[@id=basic_details_row]").first

  row.inner_html.should_not include(link)
end
