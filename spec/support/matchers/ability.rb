RSpec::Matchers.define :authorize do |action, object|
  match do |actual|
    actual.can?(action, object).should == true
  end
end

RSpec::Matchers.define :authorize_all do |actions, *objects|
  match do |actual|
    actions.product(objects).all? { |(action, object)| actual.can?(action, object) }.should == true
  end
end

RSpec::Matchers.define :authorize_any do |actions, *objects|
  match do |actual|
    actions.product(objects).any? { |(action, object)| actual.can?(action, object) }.should == true
  end
end
