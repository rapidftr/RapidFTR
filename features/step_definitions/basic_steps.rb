When /^I fill in the basic details of a child$/ do

  fill_in("Last known location", :with => "Haiti")

end

Then /^I should see the photo of the child$/ do
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty  
end