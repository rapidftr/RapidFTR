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

  validates :name, :presence => {:message => "Name must not be blank"}
  validates :permissions, :presence => {:message => I18n.t("errors.models.role.permission_presence")}
  validate :is_name_unique, :if => :name

  before_save :generate_id

  def self.find_by_name(name)
    Role.by_name(:key => name).first
  end

  def has_permission(permission)
    permissions.include? permission
  end

  def sanitize_permissions
    permissions.reject! { |permission| permission.blank? } if permissions
  end

  def is_name_unique
    role = Role.find_by_name(name)
    return true if role.nil? || id == role.id
    errors.add(:name, I18n.t("errors.models.role.unique_name"))
  end

  def valid?(context = :default)
    self.name = name.try(:titleize)
    sanitize_permissions
    super(context)
  end

  def generate_id
    self["_id"] ||= "role-#{name}".parameterize.dasherize
  end
end
