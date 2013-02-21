class ContactInformation < CouchRestRails::Document
  use_database :contact_information

  include CouchRest::Validation
  include RapidFTR::Model

  property :id
  property :name
  property :organization
  property :phone
  property :location
  property :other_information
  property :email
  property :position
  unique_id :id

  def self.get_by_id id
    result = self.all.select{|x|x.id==id}.first
    raise ErrorResponse.not_found(I18n.t("contact.not_found", :id => id)) if result.nil?
    return result
  end
  def self.get_or_create id
    result = self.all.select{|x|x.id==id}.first
    return result if !result.nil?
    new_contact_info = ContactInformation.new :id=>id
    new_contact_info.save!
    new_contact_info
  end
end
