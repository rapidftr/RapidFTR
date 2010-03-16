Then /^I should receive a CSV file with (\d+) line(?:|s)?$/ do |num_lines|
  num_lines = num_lines.to_i
  response_body.chomp.split("\n").length.should == num_lines
end
