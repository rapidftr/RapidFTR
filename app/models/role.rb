class Role < CouchRestRails::Document
  use_database :role

  include CouchRest::Validation
  include RapidFTR::Model

  property :name
  property :description
  property :permissions, :type => [String]

  view_by :name,
    :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Role') && doc['name'])
             {
                emit(doc['name'],doc);
             }
          }"

  validates_presence_of :name
  validates_presence_of :permissions, :message => "Please select at least one permission"
  validates_with_method :name, :method => :is_name_unique, :if => :name

  def is_name_unique
    return true if Role.by_name(:key => name).empty?
    [false, "A role with that name already exists, please enter a different name"]
  end

end

