class Enquiry < CouchRestRails::Document
  use_database :enquiry

  property :reporter_name

end
