When /^I filter by "(.+)"$/ do |filter_type|
  within(:css, ".filter_panel") do
    click_link(filter_type)
  end
end
