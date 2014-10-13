module Match
  class StateTransition
    @update_match_history = lambda do |match, old_status, new_status|
      match.enquiry.add_match_history(old_status, new_status) if match.enquiry
      match.child.add_match_history(old_status, new_status) if match.child
    end

    TRANSITIONS = {
      PotentialMatch::CONFIRMED => {
        PotentialMatch::POTENTIAL => [@update_match_history]
      },
      PotentialMatch::POTENTIAL => {
        PotentialMatch::CONFIRMED => [@update_match_history]
      }
    }

    def self.for(old_status, new_status)
      return [] if TRANSITIONS[old_status].nil?
      TRANSITIONS[old_status][new_status] || []
    end
  end
end
