class SearchService

  def self.search(page_number, criteria_list)
    query = SearchCriteria.lucene_query(criteria_list)
    begin
      Child.sunspot_search(page_number, query)
    rescue

    end
  end


end
