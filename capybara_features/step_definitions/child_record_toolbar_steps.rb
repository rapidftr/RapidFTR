Then /^I should see the following links in the toolbars:$/ do |links_table|
  divs = page.all :xpath, '//div[@class="profile-tools"]'
  divs.each do |div|
    links_table.hashes.each do |link_hash|
      check_link_presence(div, link_hash['link_class_name'], link_hash['link_text'])
    end
  end
end

When /^I click the "(.*)" button$/ do |button_value|
  divs = page.all "//div[@class=\"mark-as-form\"]"
  divs.each do |div|
    if div.visible?
      buttons = div.all "//input[@value=\"#{button_value}\"]"
      buttons.each do |button|
        if button.visible?
          button.click
          break
        end
      end
      break
    end
  end
end