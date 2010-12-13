Given /^I am sending a session token of "(.*)" in my request headers$/ do |token|
  header "Authorization", "RFTR_Token #{token}"
end

Given /^I am not sending a session token in my request headers$/ do
  header "Authorization", ''
  #headers.delete( "Authorization" )
end

Given /^I am sending a valid session token in my request headers$/ do
  raise "don't know which user I should create a session for" if @user.nil?
  session = Session.for_user(@user)
  session.save!
  Given %Q|I am sending a session token of "#{session.id}" in my request headers|
end

When /^I visit the "([^"]*)" tab$/ do |name_of_tab|
  click_link name_of_tab
end


Then /^(?:|I )should see a link to the (.+)$/ do |page_name|
  response_body.should have_selector("a[href='#{path_to(page_name)}']")
end

Then /^show me the cookies$/ do
  puts "COOKIES:"
  puts cookies.inspect
end

Then /^I should have received a "(.+)" status code$/ do |status_code|
  response.status.should == status_code
end

Then /^I should find the following links:$/ do |table|
  table.rows_hash.each do |label, named_path|
    href = path_to(named_path)
    assert_have_xpath "//a[@href='#{href}' and text()='#{label}']"
  end
end

Then /^I should find the form with following attributes:$/ do |table|
  table.raw.each do |attribute|
    assert_contain attribute.first
  end
end

Then /^the "([^\"]*)" field should be disabled$/ do |label|
  field_labeled(label).should be_disabled
end

Then /^I should see the select named "([^\"]*)"$/ do |select_name|
  	response_body.should have_selector("select[name='#{select_name}']")
end

Then /^I should see an option "([^\"]*)" for select "([^\"]*)"$/  do | option_value, select_name|
    response_body.should have_selector("select[name='#{select_name}'] option[value=#{option_value}]")
end

Then /^the "([^"]*)" radio_button should have the following options:$/ do |radio_button, table|
   radios = Nokogiri::HTML(response.body).css(".radioList")
   radio = radios.detect {|radio| radio.css("dt").first.text == radio_button}
   radio.should_not be_nil
   radio.css("label").map(&:text).should == table.raw.map(&:first)
end

Then /^the "([^"]*)" dropdown should have the following options:$/ do |dropdown_label, table|
  dropdown_field = field_labeled(dropdown_label)
  actual_option_labels = dropdown_field.options.map(&:label)

  selected_option = dropdown_field.element.search(".//*[@selected='selected']").first

  table.hashes.each do |expected_option|
    expected_label = expected_option['label']
    should_be_selected = (expected_option['selected?'] == 'yes')

    actual_option_labels.should include(expected_label)
    if should_be_selected
      selected_option.text.should == expected_label
    end
  end
end

Then /^I should not be able to see (.+)$/ do |page_name|
  lambda { visit path_to(page_name) }.should raise_error(AuthorizationFailure)
end

Then /^I should be able to see (.+)$/ do |page_name|
  When "I go to #{page_name}"
  Then "I should be on #{page_name}"
end

Then /^I should see an audio element that can play the audio file named "([^"]*)"$/ do |filename|
  response_body.should have_selector("audio source", :src=>"todo") 
end


