require 'spec/spec_helper'

Given /^the following form sections exist in the system:$/ do |form_sections_table|
  FormSection.all.each {|u| u.destroy }

  form_sections_table.hashes.each do |form_section_hash|
    form_section_hash.reverse_merge!(
      'unique_id'=> form_section_hash["name"].gsub(/\s/, "_").downcase,
      'enabled' => true,
      'fields'=> Array.new
    )

    form_section_hash["order"] = form_section_hash["order"].to_i
    FormSection.create!(form_section_hash)
  end
end

Given /^the following fields exists on "([^"]*)":$/ do |form_section_name, table|
  form_section = FormSection.get_by_unique_id(form_section_name)
  form_section.should_not be_nil
  form_section.fields = []
  table.hashes.each do |field_hash|
    field_hash.reverse_merge!(
      'enabled' => true,
      'type'=> Field::TEXT_FIELD
    )
    form_section.fields.push Field.new(field_hash)
  end
  form_section.save!
end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  current_time.stub!(:getutc).and_return Time.parse(datetime)
  Time.stub!(:now).and_return current_time
end

When /^the local date\/time is "([^\"]*)" and UTC time is "([^\"]*)"$/ do |datetime, utcdatetime|
  current_time = Time.parse(datetime)
  current_time_in_utc = Time.parse(utcdatetime)
  Time.stub!(:now).and_return current_time
  current_time.stub!(:getutc).and_return current_time_in_utc
end

Then /^I should see (\d*) divs of class "(.*)"$/ do |quantity, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
end

Then /^I should see (\d*) divs with text "(.*)" for class "(.*)"$/ do |quantity, div_text, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
  divs.each do |div|
    div.text.should == div_text
  end
end

When /^I sleep (\d*) seconds$/ do |sleep_time|
  sleep sleep_time.to_i
end
