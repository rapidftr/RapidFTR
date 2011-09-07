
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