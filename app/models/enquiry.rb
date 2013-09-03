class Enquiry < CouchRestRails::Document
  use_database :enquiry
  include RapidFTR::Model


  property :reporter_name

  def update_from(properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
  end
end
