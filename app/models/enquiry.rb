class Enquiry < CouchRestRails::Document
  use_database :enquiry
  include RapidFTR::Model
  include RecordHelper

  def initialize(user, *args)
    self.set_creation_fields_for(user)
    super *args
  end

  property :reporter_name

  def update_from(properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
  end
end
