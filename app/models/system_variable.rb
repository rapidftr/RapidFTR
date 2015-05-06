class SystemVariable < CouchRest::Model::Base
  use_database :system_setting

  property :name, String
  property :value, String
  property :type, String, :default => 'string'

  validates :name, :presence => true, :uniqueness => true
  validates :value, :presence => true
  validates :type, :presence => true, :inclusion => { :in => ['boolean', 'string', 'number'], :message => 'unknown type'}

  # the type of the
  design do
    view :by_name
  end

  SCORE_THRESHOLD = 'SCORE_THRESHOLD'

end
