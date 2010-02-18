class SearchRequest < CouchRestRails::Document
  use_database :search_request

  property :user_name

  def initialize(for_user_name, *args)
    super args
    @user_name = for_user_name
  end
end