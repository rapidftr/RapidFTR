class MatchService
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
