When /^I check the Basic Identity form section checkbox$/ do
  all(:xpath, "//input[@type='checkbox']")[1].click
end

When /^I check the Enquiry Criteria form section checkbox$/ do
  find_field('default_forms[[forms]][enquiries][[sections]][enquiry_criteria][user_selected]').click
end
