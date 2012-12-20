Then /^I should not see pagination links$/ do
  page.should have_no_selector(:css, 'nav.pagination')
end

Then /^I should see pagination links for first page$/ do
  page.should have_selector(:css, 'div.pagination')
  page.should have_selector(:css, 'div.pagination a.next_page')
  page.should have_selector(:css, 'div.pagination span.previous_page')
  page.find(:css, 'div.pagination em.current').should have_content('1')
end

Then /^I should see pagination links for last page$/ do
  page.should have_selector(:css, 'div.pagination')
  page.should have_selector(:css, 'div.pagination a.previous_page')
  page.should have_selector(:css, 'div.pagination span.next_page')
  page.find(:css, 'div.pagination em.current').should have_content('2')
end

Then /^I should see "([^\"]*)" children on the page$/ do |number_of_records|
  page.all(:css,'.child_summary_panel').count.should eq number_of_records.to_i
end

And /^I should see children listing page "([^\"]*)"$/ do | page_number|
  page.find(:css, 'div.pagination em.current').should have_content(page_number)
end

And /^I visit children listing page "([^\"]*)"$/ do|page_number|
  page.find(:css,'div.pagination').click_link(page_number)
end

