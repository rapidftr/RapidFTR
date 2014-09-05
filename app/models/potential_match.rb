class PotentialMatch < CouchRest::Model::Base
  use_database :potential_match

  belongs_to :enquiry
  belongs_to :child
  property :marked_invalid, TrueClass, :default => false

  validates :child_id, :uniqueness => {:scope => :enquiry_id}

  design do
    view :by_enquiry_id
    view :by_enquiry_id_and_child_id
    view :all_valid_enquiry_ids,
         :map => "function(doc) {
                    if(doc['couchrest-type'] == 'PotentialMatch' && !doc['marked_invalid']) {
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
    def create_matches_for_enquiry(enquiry_id, child_ids)
      child_ids.each do |id|
        pm = PotentialMatch.new :enquiry_id => enquiry_id, :child_id => id
        pm.save
      end
    end
  end
end
