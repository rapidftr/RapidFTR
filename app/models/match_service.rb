class MatchService

  def self.search_for_matching_children(criteria)
    search = Sunspot.search(Child) do
      fulltext criteria.values.join(' '), minimum_match: 1
    end
    search.results
  end

end
