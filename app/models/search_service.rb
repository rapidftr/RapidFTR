class SearchService
  
  def self.search(criteria_list)
    query = SearchCriteria.lucene_query(criteria_list)
    Child.sunspot_search(query)
  end 

  def self.filter_by_date(search_results, created_at_begin, created_at_end)
    child_records = []
    date_start = created_at_begin.blank? ? nil : Time.parse(created_at_begin)
    date_end = created_at_end.blank? ? nil : Time.parse(created_at_end)

    search_results.each do |child|
      created_at = Time.parse(child.created_at)

      if date_start && date_end
      	if(created_at.between?(date_start, date_end))
      		child_records << child
      	end
      else
		child_records << child if(date_start && created_at > date_start)
      	child_records << child if(date_end   && created_at < date_end)
	  end
    end

    child_records
  end 
end