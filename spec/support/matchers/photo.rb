RSpec::Matchers.define :match_photo do |expected|
  match do |actual|
    expected.data.size == actual.data.size
  end

  failure_message do |actual|
    "photo '#{actual.name}' has a different size (#{actual.data.size}) compared to '#{expected.path}' (#{expected.data.size})"
  end

  failure_message_when_negated do |actual|
    "photo '#{actual.name}' has the same size as  '#{expected.path}' (#{expected.data.read})"
  end

  description do
    "match photo contained in #{expected}"
  end
end
