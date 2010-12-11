class ContactInformation < CouchRestRails::Document
  use_database :contact_information
  property :id
  property :name
  view_by :id
  
  def self.get_by_id id
    by_id(:key => id).first
  end
end