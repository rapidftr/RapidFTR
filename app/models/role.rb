class Role < CouchRestRails::Document
  use_database :role

  include CouchRest::Validation
  include RapidFTR::Model

  property :name
  property :description
  property :permissions, :type => [String]

  view_by :name,
    :map => "function(doc) {
              if ((doc['couchrest-type'] == 'Role') && doc['name']) {
                emit(doc['name'], doc);
             }
          }"

  validates_presence_of :name
  validates_presence_of :permissions, :message => I18n.t("models.role.validation.error_message.permission_presence")
  validates_with_method :name, :method => :is_name_unique, :if => :name

  def self.find_by_name(name)
    Role.by_name(:key => name).first
  end

  def has_permission(permission)
    self.permissions.include? permission
  end

  def sanitize_permissions
    self.permissions.reject! { |permission| permission.blank? } if self.permissions
  end

  def is_name_unique
    role = Role.find_by_name(name)
    return true if role.nil? or self.id == role.id
    [false, I18n.t("models.role.validation.error_message.unique_name")]
  end

  def valid?(context = :default)
    self.name = self.name.try(:titleize)
    sanitize_permissions
    super(context)
  end

end

