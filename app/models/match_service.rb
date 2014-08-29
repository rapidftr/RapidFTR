class MatchService
  def self.search_for_matching_children(criteria, id_of_record_to_exclude = nil)
    search = Sunspot.search(Child) do
      fulltext criteria.values.join(' '), :minimum_match => 1
    end
    search.results.to_a.select { |result| result.id != id_of_record_to_exclude }
  end
end
