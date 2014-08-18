module CanCan
  class CustomRule < Rule
    def initialize(base_behavior, action, subject, conditions, block)
      @except_actions = [conditions.try(:delete, :except)].flatten.compact
      super(base_behavior, action, subject, conditions, block)
    end

    def matches_action?(action)
      (@expanded_actions.include?(:manage) && @except_actions.exclude?(action)) || @expanded_actions.include?(action)
    end
  end
end
