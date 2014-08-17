When /^I make sure that the Replication Configuration request succeeds$/ do
  RSpec::Mocks.space.proxy_for(Net::HTTP).reset
  allow(Net::HTTP).to receive(:post_form) do |*args|
    double :body => {"target" => "http://localhost:1234", "databases" => {}}.to_json
  end
end

When /^I make sure that the Replication Configuration request fails$/ do
  RSpec::Mocks.space.proxy_for(Net::HTTP).reset
  allow(Net::HTTP).to receive(:post_form).and_raise("some http error")
end

When /^I clear the Replication Configuration expectations$/ do
  RSpec::Mocks.space.proxy_for(Net::HTTP).reset
end
