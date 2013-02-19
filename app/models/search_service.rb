class SearchService

  def self.search(page_number, criteria_list)
    query = SearchCriteria.lucene_query(criteria_list)
    Child.sunspot_search(page_number, query)
  end


end
