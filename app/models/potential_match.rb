class PotentialMatch < CouchRest::Model::Base
  use_database :potential_match

  belongs_to :enquiry
  belongs_to :child
  property :marked_invalid, TrueClass, :default => false
  property :confirmed, TrueClass, :default => false
  property :score, String
  property :deleted, TrueClass, :default => false
  timestamps!
  validates :child_id, :uniqueness => {:scope => :enquiry_id}

  design do
    view :by_enquiry_id
    view :by_child_id
    view :by_enquiry_id_and_child_id
    view :by_enquiry_id_and_confirmed
    view :by_enquiry_id_and_marked_invalid
    view :by_enquiry_id_and_deleted
    view :by_child_id_and_confirmed
    view :all_valid_enquiry_ids,
         :map => "function(doc) {
                    if(doc['couchrest-type'] == 'PotentialMatch' && !doc['marked_invalid'] && !doc['confirmed']) {
                        emit(doc['enquiry_id'], null);
                      }
                   }",
         :reduce => "function(key, values) {
                       return null;
                     }"
  end

  def mark_as_invalid
    self[:marked_invalid] = true
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
end
