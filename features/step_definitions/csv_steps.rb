Then /^I should receive a CSV file with (\d+) line(?:|s)?$/ do |num_lines|
  num_lines = num_lines.to_i
  response.content_type.should == "text/csv"
  response_body.chomp.split("\n").length.should == num_lines
end

Then /^the CSV data should be:$/ do |expected_csv|
  downloaded_csv = FasterCSV.parse(response.body)
  index_of_name_column = downloaded_csv[0].index "name"
  expected_csv.hashes.each do |expected_line|
    matching_line = downloaded_csv.find do |line|
      line[index_of_name_column] == expected_line["name"]
    end
    matching_line.should_not be_nil
    expected_line.each_key do |key|
      matching_line.should contain expected_line[key]
    end
  end
end

Then /^the CSV filename should be "(.+)"$/ do |filename|
   response.headers["content-disposition"].should == "attachment; filename=\"#{filename}\""
end