class SystemUsers < CouchRestRails::Document
  include CouchRest::Validation
  include RapidFTR::Model
  self.database = COUCHDB_SERVER.database("_users")

  property :name
  property :password
  property :type
  property :roles
  property :_id

  validates_presence_of :name, :password

  validates_with_method :name, :method => :is_user_name_unique

  before_save :generate_id, :assign_admin_role

  private

  def generate_id
    self._id = "org.couchdb.user:#{self.name}"
  end

  def is_user_name_unique
    user = SystemUsers.get(generate_id)
    return true if user.nil? or self._id == user._id
    [false, I18n.t("activerecord.errors.models.system_users.username_unique")]
  end

  def assign_admin_role
    self.roles = ["admin"]
    self.type = "user"
  end

end