class MatchService

  def self.search_for_matching_children(criteria)
    query = MatchCriteria.dismax_query(criteria)
    Child.sunspot_matches(query)
  end

end