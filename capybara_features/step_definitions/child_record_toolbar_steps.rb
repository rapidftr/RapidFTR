Then /^I should see (\d*) divs of class "(.*)"$/ do |quantity, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
end

Then /^I should see the following links in the toolbars:$/ do |links_table|
  divs = page.all :xpath, '//div[@class="profile-tools"]'
  divs.each do |div|
    links_table.hashes.each do |link_hash|
      check_link_presence(div, link_hash['link_class_name'], link_hash['link_text'])
    end
  end
end


def check_link_presence(div, li_class_name, link_text)
  lis = div.all :xpath, "//li[@class=\"#{li_class_name}\"]"
  lis.size.should >= 1
  found = false
  lis.each do |li|
    begin
      li.find('a', :text => link_text)!=nil
      found = true
      break
    rescue Capybara::ElementNotFound
    end
  end
  found.should_not be_false
end