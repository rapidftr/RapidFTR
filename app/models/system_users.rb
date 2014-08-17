class SystemUsers < CouchRest::Model::Base

  include RapidFTR::Model
  self.database = COUCHDB_SERVER.database("_users")

  property :name
  property :password
  property :type
  property :roles
  property :_id

  before_save :generate_id, :assign_admin_role

  design do
    view :all,
         :map => "function(doc) {
             if (doc['couchrest-type'] == 'SystemUsers') {
                 emit(doc['_id'],1);
             }
         }"
  end

  private

  def generate_id
    self._id = "org.couchdb.user:#{name}"
  end

  def is_user_name_unique
    user = SystemUsers.get(generate_id)
    return true if user.nil? || _id == user._id
    [false, I18n.t("errors.models.system_users.username_unique")]
  end

  def assign_admin_role
    self.roles = ["admin"]
    self.type = "user"
  end

end
