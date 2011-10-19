class SearchService
  
  def self.search(criteria_list)
    query = SearchCriteria.lucene_query(criteria_list)

    Child.sunspot_search(query)

  end 


end
