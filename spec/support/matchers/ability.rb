RSpec::Matchers.define :authorize do |action, object|
  match do |ability|
    ability.can? action, object
  end

  failure_message_for_should do |ability|
    "Expected Permissions #{ability.user.permissions.inspect} To Authorize #{action.to_s} On #{object.inspect}"
  end

  failure_message_for_should_not do |ability|
    "Did not expect User #{ability.user.inspect} To Authorize #{action.to_s} On #{object.inspect}"
  end
end

RSpec::Matchers.define :authorize_all do |actions, *objects|
  match do |ability|
    actions.product(objects).all? do |(action, object)| 
      @action, @object = [ action, object ]
      ability.can? action, object
    end
  end

  failure_message_for_should do |ability|
    "Expected User #{ability.user.inspect} To Authorize #{@action.to_s} On #{@object.inspect}"
  end

  failure_message_for_should_not do |ability|
    "Did not expect User #{ability.user.inspect} To Authorize #{@action.to_s} On #{@object.inspect}"
  end
end

RSpec::Matchers.define :authorize_any do |actions, *objects|
  match do |ability|
    actions.product(objects).any? do |(action, object)| 
      @action, @object = [ action, object ]
      ability.can? action, object
    end
  end

  failure_message_for_should_not do |ability|
    "Did not expect User #{ability.user.inspect} To Authorize #{@action.inspect} On #{@object.inspect}"
  end
end
