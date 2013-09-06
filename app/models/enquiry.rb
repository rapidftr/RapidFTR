class Enquiry < CouchRestRails::Document
  use_database :enquiry
  include RapidFTR::Model
  include RecordHelper

  def self.new_with_user_name (user, *args)
    enquiry = new *args
    enquiry.set_creation_fields_for(user)
    enquiry
  end

  property :reporter_name

  def update_from(properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
  end
end
