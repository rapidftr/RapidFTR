class SystemUsers < CouchRestRails::Document
  include CouchRest::Validation
  include RapidFTR::Model

  use_database :_users

  property :name
  property :password
  property :type
  property :roles
  property :_id

  validates_presence_of :name, :password, :roles

  validates_with_method :name, :method => :is_user_name_unique

  before_save :generate_id

  private

  def generate_id
    self._id = "org.couchdb.user:#{self.name}"
  end

  def is_user_name_unique
    user = SystemUsers.get("org.couchdb.user:#{self.name}")
    return true if user.nil?
    [false, "User name has already been taken! Please select a new User name"]
  end

end