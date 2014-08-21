Then /^I should not see pagination links$/ do
  child_list_page.should_not_be_paged
end

Then /^I should see pagination links for first page$/ do
  child_list_page.should_be_showing_first_page
end

Then /^I should see pagination links for last page$/ do
  child_list_page.should_be_showing_last_page
end

Then /^I should see "([^\"]*)" children on the page$/ do |number_of_records|
  child_list_page.should_be_showing(number_of_records.to_i)
end

And /^I should see children listing page "([^\"]*)"$/ do | page_number|
  child_list_page.should_be_on_page(page_number)
end

And /^I visit children listing page "([^\"]*)"$/ do|page_number|
  child_list_page.go_to_page(page_number)
end

And /^I select dropdown option "(.+)"$/ do |option|
  page.find('//option', :text => option).click
end

When /^I sort "(.*?)"$/  do |sort_order|
  child_list_page.sort(sort_order)
end

private

def child_list_page
  @_child_list_page ||= EntityListPage.new(Capybara.current_session)
end
