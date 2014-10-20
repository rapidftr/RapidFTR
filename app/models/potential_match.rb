class PotentialMatch < CouchRest::Model::Base
  use_database :potential_match

  belongs_to :enquiry
  belongs_to :child
  property :score, String
  property :status, String, :default => 'POTENTIAL'
  timestamps!
  validates :child_id, :uniqueness => {:scope => :enquiry_id}
  before_save :load_transitions
  after_save :handle_state_transition

  POTENTIAL = 'POTENTIAL'
  DELETED = 'DELETED'
  INVALID = 'INVALID'
  CONFIRMED = 'CONFIRMED'
  REUNITED = 'REUNITED'
  REUNITED_ELSEWHERE = 'REUNITED_ELSEWHERE'

  design do
    view :by_enquiry_id
    view :by_child_id
    view :by_enquiry_id_and_child_id
    view :by_enquiry_id_and_status
    view :by_enquiry_id_and_marked_invalid
    view :by_child_id_and_status
    view :all_valid_enquiry_ids,
         :map => "function(doc) {
                    if(doc['couchrest-type'] == 'PotentialMatch' && doc['status'] == '#{PotentialMatch::POTENTIAL}') {
                        emit(doc['enquiry_id'], null);
                      }
                   }",
         :reduce => "function(key, values) {
                       return null;
                     }"
  end

  def mark_as_invalid
    mark_as_status(PotentialMatch::INVALID)
  end

  def marked_invalid?
    marked_as?(PotentialMatch::INVALID)
  end

  def mark_as_confirmed
    mark_as_status(PotentialMatch::CONFIRMED)
  end

  def confirmed?
    marked_as?(PotentialMatch::CONFIRMED)
  end

  def mark_as_reunited
    mark_as_status(PotentialMatch::REUNITED)
  end

  def reunited?
    marked_as?(PotentialMatch::REUNITED)
  end

  def mark_as_reunited_elsewhere
    mark_as_status(PotentialMatch::REUNITED_ELSEWHERE)
  end

  def reunited_elsewhere?
    marked_as?(PotentialMatch::REUNITED_ELSEWHERE)
  end

  def mark_as_deleted
    mark_as_status(PotentialMatch::DELETED)
  end

  def deleted?
    marked_as?(PotentialMatch::DELETED)
  end

  def mark_as_potential_match
    mark_as_status(PotentialMatch::POTENTIAL)
  end

  def potential_match?
    marked_as?(PotentialMatch::POTENTIAL)
  end

  class << self
    def update_matches_for_child(child_id, hits)
      hits.each do |enquiry_id, score|
        enquiry_is_reunited = Enquiry.get(enquiry_id).reunited?
        update_potential_match(child_id, enquiry_id, score.to_f) unless enquiry_is_reunited
      end
    end

    def update_matches_for_enquiry(enquiry_id, hits)
      enquiry = Enquiry.get(enquiry_id)
      unless enquiry.reunited?
        hits.each { |child_id, score| update_potential_match(child_id, enquiry_id, score.to_f) }
      end
    end

    private

    def update_potential_match(child_id, enquiry_id, score)
      threshold = SystemVariable.find_by_name(SystemVariable::SCORE_THRESHOLD).value.to_f
      pm = find_or_build enquiry_id, child_id
      pm.score = score
      valid_score = score >= threshold
      should_mark_deleted = !valid_score && !pm.new? && !pm.deleted?
      if should_mark_deleted
        pm.mark_as_deleted
        pm.save
      elsif valid_score
        pm.mark_as_potential_match if pm.deleted?
        pm.save
      end
    end

    def find_or_build(enquiry_id, child_id)
      potential_match = by_enquiry_id_and_child_id.key([enquiry_id, child_id]).first
      return potential_match unless potential_match.nil?
      PotentialMatch.new :enquiry_id => enquiry_id, :child_id => child_id
    end
  end

  private

  def load_transitions
    @old_status = changed_attributes && changed_attributes[:status]
    @old_status = changed_attributes && changed_attributes['status'] if @old_status.nil?
    @transitions = Match::StateTransition.for(@old_status, status)
  end

  def handle_state_transition
    @transitions.each do |transition_hook|
      transition_hook.call(self, @old_status, status)
    end
    @transitions = []
    @old_status = nil
  end

  def mark_as_status(status)
    self[:status] = status
  end

  def marked_as?(status)
    self[:status] == status
  end
end
