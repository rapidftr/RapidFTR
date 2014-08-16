Then /^I should see the following links in the toolbars:$/ do |links_table|
  divs = page.all :xpath, '//div[@class="profile-tools"]'
  divs.each do |div|
    links_table.hashes.each do |link_hash|
      check_link_presence(div, link_hash['link_class_name'], link_hash['link_text'])
    end
  end
end

And /^I mark as investigated with the following details:$/ do |details|
  child_record_toolbar.mark_as_investigated(details)
end

And /^I mark as not investigated with the following details:$/ do |details|
  child_record_toolbar.mark_as_not_investigated(details)
end

When /^I click mark as duplicate for "([^"]*)"$/ do |child_name|
  child_record_toolbar.mark_as_duplicate(child_name)
end

When /^I click blacklist for "([^"]*)"$/ do |imei|
  device_list_page.blacklist_device(imei)
end

When /^I view User Action History$/ do
  child_record_toolbar.view_user_action_history
end

private

def child_record_toolbar
  @_child_record_toolbar_widget ||= ChildRecordToolbarWidget.new(Capybara.current_session)
end

def device_list_page
  @_device_list_page ||= DeviceListPage.new(Capybara.current_session)
end
