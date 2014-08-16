Then /^I should receive a PDF file$/ do
  Tempfile.open('rapidftr_cuke_tests') do |temp_file|
    temp_file.write(page.source)
    temp_file.close
    mimetype = `file --brief --mime #{temp_file.path}`.gsub(/\n/,"")
    expect(mimetype).to match(/application\/pdf/)
  end
end

Then /^the PDF file should have (\d+) page(?:|s)$/ do |num_pages|
  num_pages = num_pages.to_i

  pdf = PDF::Inspector::Page.analyze(page.source)
  expect(pdf).to have(num_pages).pages
end

Then /^the PDF file should contain the string "([^\"]*)"$/ do |expected_string|
  pdf = PDF::Inspector::Text.analyze(page.source)
  expect(pdf.strings).to include(expected_string)
end

Then /^the PDF file should not contain the string "([^\"]*)"$/ do |expected_string|
  pdf = PDF::Inspector::Text.analyze(page.source)
  expect(pdf.strings).not_to include(expected_string)
end

Then /^I should receive a CSV file with (\d+) lines?$/ do |num_lines|
  num_lines = num_lines.to_i
  expect(page.response_headers['Content-Type']).to eq('text/csv')
  expect(page.text.chomp.split("\n").length).to eq(num_lines)
end

Then /^the CSV data should be:$/ do |expected_csv|
  downloaded_csv = CSV.parse(page.text)
  index_of_name_column = downloaded_csv[0].index 'Name'
  expected_csv.hashes.each do |expected_line|
    matching_line = downloaded_csv.find do |line|
      line[index_of_name_column] == expected_line['name']
    end
    expect(matching_line).not_to be_nil
    expected_line.each_key do |key|
      expect(matching_line).to include expected_line[key]
    end
  end
end

Then /^the response filename should be "(.+)"$/ do |filename|
  expect(page.response_headers['content-disposition']).to eq("attachment; filename=\"#{filename}\"")
end
