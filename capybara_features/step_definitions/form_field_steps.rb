Given /^the following suggested fields exist in the system:$/ do |suggested_fields_table|
  suggested_fields_table.hashes.each do |suggested_field_hash|
    suggested_field_hash.reverse_merge!(
            'unique_id'=> suggested_field_hash["name"].gsub(/\s/, "_").downcase)

    field = Field.new :name => suggested_field_hash["name"],
                      :type => suggested_field_hash["type"],
                      :help_text => suggested_field_hash["help_text"],
                      :display_name => suggested_field_hash["display_name"],
                      :option_strings_text => (eval suggested_field_hash["option_strings"])
    suggested_field_hash[:field] = field
    suggested_field_hash[:is_used] = false
    temp1 = SuggestedField.create!(suggested_field_hash)
  end
end

And /^I should see "([^\"]*)" in the list of visible fields$/ do |field_id|
  page.should have_css(".rowEnabled")
  field_ids = page.all(:css, ".rowEnabled").map {|row| row[:id] }
  field_ids.should include("#{field_id}Row")
end


When /^I click the "(.*?)" arrow on "(.*?)" field$/ do |arrow_name, field_name|
  click_link(field_name.dehumanize + "_" + arrow_name.dehumanize);
end

Then /^I should (not )?see the following suggested fields:$/ do |negative, expected_table|
  within :css, '#suggestedFields' do
    expected_table.hashes.each do |expected_row|
      row_class = "#{expected_row[:unique_id]}Display"
      if negative
        page.should_not have_css(".#{row_class}")
      else
        page.should have_css(".#{row_class}")
        page.find(:css, ".#{row_class} .displayName").text.strip.should == expected_row[:name]
        page.find(:css, ".#{row_class} .helpText").text.strip.should == expected_row[:help_text]
      end
    end
  end
end

When /^I choose to add suggested field "([^\"]*)"$/ do |field_id|
   within :css, ".#{field_id}Display" do
     click_button("Add to form")
   end
end

Then /^I should not be able to edit "([^\"]*)" field$/ do |field_name|
  page.should have_no_selector(:xpath, "//td[text()=\"#{field_name}\"]/parent::*/td/div/select")
end

Then /^I should be able to edit "([^\"]*)" field$/ do |field_name|
  page.should have_selector(:xpath, "//td[text()=\"#{field_name}\"]/parent::*/td/div/select")
end

When /^(?:|I )move field "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

Then /^(?:|I )move field "([^"]*)" to form "([^"]*)"$/ do |field_name, form_name|
   #//td[text()='#{field_name}']/parent::tr/td[6]/a
   page.find("//tr[@data='#{field_name}']/td[6]/a").click
   sleep 1.to_i
   page.select(form_name, :from => "#{field_name}_destination_form_id")
end



