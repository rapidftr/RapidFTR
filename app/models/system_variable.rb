class SystemVariable < CouchRest::Model::Base
  use_database :system_setting

  property :name, String
  property :value, String

  validates :name, :presence => true, :uniqueness => true
  validates :value, :presence => true

  design do
    view :by_name
  end

  SCORE_THRESHOLD = 'SCORE_THRESHOLD'
end
