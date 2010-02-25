class Session < CouchRestRails::Document
  use_database :sessions

  property :user_name
end
