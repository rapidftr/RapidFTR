module Match
  class StateTransition
    @update_match_history = lambda do |match, old_status, new_status|
      match.enquiry.add_match_history(old_status, new_status) if match.enquiry
      match.child.add_match_history(old_status, new_status) if match.child
    end

    @mark_enquiry_as_not_reunited = lambda do |match, _old_status, _new_status|
      match.enquiry.update_attributes :reunited => false
    end

    @update_enquiry_matches = lambda do |match, _old_status, _new_status|
      matches = PotentialMatch.by_enquiry_id_and_status.key([match.enquiry_id, PotentialMatch::REUNITED_ELSEWHERE])
      matches.each { |m| m.update_attributes :status => PotentialMatch::POTENTIAL }
    end

    LEAVING_STATUS = {
      PotentialMatch::CONFIRMED => [@update_match_history],
      PotentialMatch::INVALID => [@update_match_history],
      PotentialMatch::REUNITED => [@update_match_history]
    }

    ENTERING_STATUS = {
      PotentialMatch::CONFIRMED => [@update_match_history],
      PotentialMatch::INVALID => [@update_match_history],
      PotentialMatch::REUNITED => [@update_match_history]
    }

    TRANSITIONS = {
      PotentialMatch::REUNITED => {
        PotentialMatch::REUNITED_ELSEWHERE => [@mark_enquiry_as_not_reunited]
      },
      PotentialMatch::REUNITED => {
        PotentialMatch::POTENTIAL => [@update_enquiry_matches,
                                      @mark_enquiry_as_not_reunited]
      }
    }

    def self.for(old_status, new_status)
      transitions = []
      transitions << LEAVING_STATUS[old_status]
      transitions << ENTERING_STATUS[new_status]
      transitions << state_specific_transitions(old_status, new_status)
      transitions.flatten.compact.uniq
    end

    def self.state_specific_transitions(old_status, new_status)
      from_transitions = TRANSITIONS[old_status].nil? ? {} : TRANSITIONS[old_status]
      from_transitions[new_status]
    end
  end
end
