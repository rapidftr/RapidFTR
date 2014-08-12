When /^I check the Basic Identity form section checkbox$/ do
  all(:xpath, "//input[@type='checkbox']")[1].click
end

When /^I check the Enquiry Criteria form section checkbox$/ do
  all(:xpath, "//input[@type='checkbox']")[121].click
end
