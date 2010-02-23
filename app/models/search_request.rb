class SearchRequest < CouchRestRails::Document
  use_database :search_request
  
  def user_name=(value)
    self['_id'] = value
  end

  def _id
    return @user_name
  end

  def self.create_search(user_name, *fields)
    if (SearchRequest.get(user_name))
      search = SearchRequest.get(user_name)
      search.merge! fields[0]
    else
      search = SearchRequest.new(*fields)
      search.user_name = user_name
      return search
    end
  end

  def user=(value)
    self['_id'] = value
  end

  def _id
    return @user
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