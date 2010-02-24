class SearchRequest < CouchRestRails::Document
  use_database :search_request

  def user=(value)
    self['_id'] = value
  end

  def _id
    return @user
  end

  def get_results()
    Summary.basic_search(self[:child_name], self[:unique_identifier])
  end

  def self.create_search(user, *fields)
    if (SearchRequest.get(user))
      search = SearchRequest.get(user)
      search.merge! fields[0]
    else
      search = SearchRequest.new(*fields)
      search.user = user
      return search
    end
  end
end