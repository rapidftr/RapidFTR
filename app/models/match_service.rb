class MatchService
  def self.search_for_matching_enquiries(criteria)
    if criteria.nil? || criteria.empty?
      return []
    else
      search = Sunspot.search(Enquiry) do
        fulltext criteria.join(' '), :fields => Enquiry.matchable_fields.map(&:name), :minimum_match => 1
      end
      return search.results
    end
  end

  def self.search_for_matching_children(criteria)
    if criteria.nil? || criteria.empty?
      return []
    else
      search = Sunspot.search(Child) do
        fulltext criteria.values.join(' '), :minimum_match => 1
      end
      return search.results
    end
  end
end
