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

Then /^the filename should contain "(.+)"$/ do |filename|
  response.headers["content-disposition"].should contain "#{filename}"
end
