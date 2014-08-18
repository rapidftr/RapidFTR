Given /^the following reports exist in the system:$/ do |reports_table|
  reports_table.hashes.each do |hash|
    report = Report.new :report_type => hash['report_type'], :as_of_date => Date.parse(hash['as_of_date'])
    report.create_attachment :name => hash['file_name'], :file => StringIO.new(hash['data']), :content_type => hash['content_type']
    report.save!
  end
end

Given /^(\d+) reports exist in the system starting from (.+)$/ do |num_reports, start_date_str|
  start_date = Date.parse start_date_str
  (1 .. num_reports.to_i).to_a.each do |i|
    report = Report.new :report_type => 'text/csv', :as_of_date => (start_date + i.days)
    report.create_attachment :name => "test_report_#{i}.csv", :file => StringIO.new("TEST DATA #{i}"), :content_type => 'test/csv'
    report.save!
  end
end

Then /^I should see the following reports:$/ do |reports_table|
  expected_order = reports_table.hashes.map { |report| report['as_of_date'] }
  actual_order = page.all(:xpath, "//td[@class='as_of_date']").map(&:text)
  expect(actual_order).to eq(expected_order)
end

Then /^a "(.+)" file named "(.+)" should be downloaded$/ do |content_type, file_name|
  expect(page.response_headers['Content-Type']).to eq(content_type)
  expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{file_name}\"")
end

Then /^the downloaded file should have content:$/ do |content|
  expect(page.source.chomp).to eq(content.chomp)
end
