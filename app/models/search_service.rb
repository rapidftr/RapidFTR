class SearchService
  
  def self.search(criteria_list)
    query = SearchCriteria.lucene_query(criteria_list)
    Child.sunspot_search(query)
  end 

  def self.filter_by_date(search_results, date_begin, date_end, date_field)
    child_records = []
    
    date_begin = date_begin.blank? ? nil : Time.parse(date_begin)
    date_end = date_end.blank? ? nil : Time.parse(date_end)

    search_results.each do |child|
      if date_field == :created_at
        child_date_field = Time.parse(child.created_at)
      elsif date_field == :last_updated_at
        child_date_field = Time.parse(child.last_updated_at)
      end

      if date_begin && date_end
      	if(child_date_field.between?(date_begin, date_end))
      		child_records << child
      	end
      else
		    child_records << child if(date_begin && child_date_field > date_begin)
      	child_records << child if(date_end   && child_date_field < date_end)
	    end
    end

    child_records
  end 
end