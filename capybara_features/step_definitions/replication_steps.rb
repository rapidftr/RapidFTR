When /^I make sure that the Replication Configuration request succeeds$/ do
  Net::HTTP.rspec_reset
  Net::HTTP.should_receive(:post_form).any_number_of_times do |*args|
    double :body => { "target" => "http://localhost:1234", "databases" => {} }.to_json
  end
end

When /^I make sure that the Replication Configuration request fails$/ do
  Net::HTTP.rspec_reset
  Net::HTTP.should_receive(:post_form).any_number_of_times.and_raise("some http error")
end

When /^I clear the Replication Configuration expectations$/ do
  Net::HTTP.rspec_reset
end
