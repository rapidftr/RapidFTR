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

  property :user_name

  def initialize(for_user_name, *args)
    super args
    @user_name = for_user_name
  end
end