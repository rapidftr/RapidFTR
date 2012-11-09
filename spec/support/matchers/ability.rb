RSpec::Matchers.define :authorize do |action, object|
  match do |actual|
    actual.can?(action, object).should == true
  end

  failure_message_for_should do |actual|
    "expected to authorize #{action.to_s} on #{object.inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected to restrict #{action.to_s} on #{object.inspect}"
  end

  description do
    "authorize #{action.to_s} on #{object.to_s}"
  end
end
