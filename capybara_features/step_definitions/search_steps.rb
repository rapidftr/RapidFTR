require 'spec/spec_helper'

include HpricotSearch

When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i - 1
	checkbox = page.all(:css, "p[@class=checkbox] input[@type='checkbox']")[ordinal]
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|
	match = page.find('//a', :text => value)
  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end

Then /^I should see "(.*)" as reunited in the search results$/ do |child_name|
  child_link = page.find('//a', :text => child_name)
  link = child_link[:href]
  #puts 'link=' + link
  child_id = nil
  link.each('/') { |s| child_id=s }
  #puts 'child_id=' + child_id
  child_id = 'child_'+child_id
  #puts 'child_id=' + child_id
  child_div = page.find('//div', :id => child_id)
  #child_div2 = child_div.find( :xpath, 'div[@class="header"]')
  match = child_div.find(:xpath, './/img[@class="reunited"]')
  #puts 'child_div=' + child_div.to_s
  #match = page.find :xpath, "//div[@id=\"#{child_id}\"]/div[@class=\"header\"]/img[@class=\"reunited\"]"
  #match = page.find :xpath, "//div[@id=\"#{child_id}\"]//img[@class=\"reunited\"]"
  #match = page.find :xpath, "//div[@id=#{child_id}] div[@class=header]"
  #match = page.find :xpath, "//div[@id=#{child_id}]/div[@class=header]/img[@class=reunited]"
  #match = child_div.find('img', :class => 'reunited')
  #puts 'match=' + match.to_s
  match.should_not be_nil
end

Then /^I should not see "(.*)" as reunited in the search results$/ do |child_name|
  child_link = page.find('//a', :text => child_name)
  link = child_link[:href]
  #puts 'link=' + link
  child_id = nil
  link.each('/') { |s| child_id=s }
  #puts 'child_id=' + child_id
  child_id = 'child_'+child_id
  puts 'child_id=' + child_id
  child_div = page.find('//div', :id => child_id)
  #child_div2 = child_div.find( :xpath, '/div[@class="header"]')
  match = child_div.find(:xpath, './img[@class="reunited"]')
  #child_div2 = child_div.find('//div', :class => 'header')
  #match = child_div2.find('//img', :class => 'reunited')
  puts '********* ' + match[:src]
  #puts 'child_div=' + child_div.to_s
  #match = page.find :xpath, "//div[@id=\"#{child_id}\"]/div/img[@class=\"reunited\"]"
  #match = child_div.find :xpath, "//div/img[@class=\"reunited\"]"
  #match = child_div.find('img', :class => 'reunited')
  #puts 'match=' + match.to_s
  match.should be_nil
end