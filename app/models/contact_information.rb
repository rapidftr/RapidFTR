class ContactInformation < CouchRestRails::Document
  use_database :contact_information
  property :id
  property :name
  property :organization
  property :phone
  property :location
  property :other_information
  property :email
  property :position
  view_by :id
  unique_id :id
  
  def self.get_by_id id
    by_id(:key => id).first
  end
end