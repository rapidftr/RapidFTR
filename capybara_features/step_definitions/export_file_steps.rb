Then /^I should receive a PDF file$/ do
  Tempfile.open('rapidftr_cuke_tests') do |temp_file|
    temp_file.write( response_body )
    temp_file.close
    mimetype = `file --brief --mime #{temp_file.path}`.gsub(/\n/,"")
    mimetype.should =~ /application\/pdf/
  end
end

Then /^the PDF file should have (\d+) page(?:|s)$/ do |num_pages|
  num_pages = num_pages.to_i

  pdf = PDF::Inspector::Page.analyze( response_body )
  pdf.should have(num_pages).pages
end

Then /^the PDF file should contain the string "([^\"]*)"$/ do |expected_string|
  pdf = PDF::Inspector::Text.analyze( response_body )
  pdf.strings.should include(expected_string)
end

Then /^the PDF file should not contain the string "([^\"]*)"$/ do |expected_string|
  pdf = PDF::Inspector::Text.analyze( response_body )
  pdf.strings.should_not include(expected_string)
end

Then /^I should receive a CSV file with (\d+) lines?$/ do |num_lines|
  num_lines = num_lines.to_i
  page.response_headers['Content-Type'].should == "text/csv"
  page.body.chomp.split("\n").length.should == num_lines
end

Then /^the CSV data should be:$/ do |expected_csv|
  downloaded_csv = FasterCSV.parse(page.body)
  index_of_name_column = downloaded_csv[0].index "name"
  expected_csv.hashes.each do |expected_line|
    matching_line = downloaded_csv.find do |line|
      line[index_of_name_column] == expected_line["name"]
    end

    matching_line.should_not be_nil
    expected_line.each_key do |key|
      matching_line.should include expected_line[key]
    end
  end
end

Then /^the response filename should be "(.+)"$/ do |filename|
   page.response_headers["content-disposition"].should == "attachment; filename=\"#{filename}\""
end
