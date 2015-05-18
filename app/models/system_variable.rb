class SystemVariable < CouchRest::Model::Base
  use_database :system_setting

  property :name, String
  property :value, String
  property :type, String, :default => 'string'
  property :user_editable, TrueClass, :default => true


  validates :name, :presence => true, :uniqueness => true
  validates :value, :presence => true
  validates :type, :presence => true, :inclusion => {:in => %w(boolean string number), :message => 'unknown type'}

  # the type of the
  design do
    view :by_name
  end

  SCORE_THRESHOLD = 'SCORE_THRESHOLD'
  ENABLE_ENQUIRIES = 'ENABLE_ENQUIRIES'

  def to_bool_value
    unless value.nil?
      if value == 'true' || value == '1'
        return true
      end
    end

    false
  end
end
