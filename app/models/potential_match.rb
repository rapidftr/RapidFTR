class PotentialMatch < CouchRest::Model::Base
  use_database :potential_match

  belongs_to :enquiry
  belongs_to :child
  property :score, String
  property :status, String, :default => 'POTENTIAL'
  timestamps!
  validates :child_id, :uniqueness => {:scope => :enquiry_id}

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
    return marked_as?(PotentialMatch::INVALID)
  end

  def mark_as_confirmed
    mark_as_status(PotentialMatch::CONFIRMED)
  end

  def confirmed?
    return marked_as?(PotentialMatch::CONFIRMED)
  end

  def mark_as_reunited
    mark_as_status(PotentialMatch::REUNITED)
  end

  def reunited?
    return marked_as?(PotentialMatch::REUNITED)
  end

  def mark_as_reunited_elsewhere
    mark_as_status(PotentialMatch::REUNITED_ELSEWHERE)
  end

  def reunited_elsewhere?
    return marked_as?(PotentialMatch::REUNITED_ELSEWHERE)
  end

  def mark_as_deleted
    mark_as_status(PotentialMatch::DELETED)
  end

  def deleted?
    return marked_as?(PotentialMatch::DELETED)
  end

  def mark_as_potential_match
    mark_as_status(PotentialMatch::POTENTIAL)
  end

  def potential_match?
    return marked_as?(PotentialMatch::POTENTIAL)
  end

  class << self
    def create_matches_for_child(child_id, hits)
      hits.each do |enquiry_id, score|
        pm = PotentialMatch.new :enquiry_id => enquiry_id, :child_id => child_id, :score => score
        pm.save
      end
    end

    def create_matches_for_enquiry(enquiry_id, hits)
      hits.each do |child_id, score|
        pm = PotentialMatch.new :enquiry_id => enquiry_id, :child_id => child_id, :score => score
        pm.save
      end
    end
  end

  private

  def mark_as_status(status)
    self[:status] = status
  end

  def marked_as?(status)
    return self[:status] == status
  end
end
