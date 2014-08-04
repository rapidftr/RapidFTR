class Form < CouchRest::Model::Base
  include RapidFTR::Model
  use_database :form

  property :name

  design do
    view :by_name
  end

  def self.find_or_create_by_name name
    form = Form.by_name.key(name).first
    form.nil? ? Form.create(name: name) : form
  end
end
