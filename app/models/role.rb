class Role < CouchRest::Model::Base
  use_database :role

  include RapidFTR::Model

  property :name
  property :description
  property :permissions, :type => [String]

  design do
    view :by_name,
         :map => "function(doc) {
             if ((doc['couchrest-type'] == 'Role') && doc['name']) {
               emit(doc['name'], doc);
             }
         }"
  end

  validates_presence_of :name, :message => "Name must not be blank"
  validates_presence_of :permissions, :message => I18n.t("errors.models.role.permission_presence")
  validate :is_name_unique, :if => :name

  before_save :generate_id

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
    errors.add(:name, I18n.t("errors.models.role.unique_name"))
  end

  def valid?(context = :default)
    self.name = self.name.try(:titleize)
    sanitize_permissions
    super(context)
  end

  def generate_id
    self["_id"] ||= "role-#{self.name}".parameterize.dasherize
  end

end
