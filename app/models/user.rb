require 'digest/sha2'
class User < CouchRestRails::Document
  use_database :user
  include CouchRest::Validation
  include RapidFTR::Model

  property :full_name
  property :user_name
  property :verified, :cast_as => :boolean, :default => true
  property :crypted_password
  property :salt

  property :phone
  property :email
  property :organisation
  property :position
  property :location
  property :disabled, :cast_as => :boolean, :default => false
  property :mobile_login_history, :cast_as => ['MobileLoginEvent']
  property :role_ids, :type => [String]
  property :time_zone, :default => "UTC"
  property :locale

  attr_accessor :password_confirmation, :password
  ADMIN_ASSIGNABLE_ATTRIBUTES = [:role_ids]


  timestamps!

  view_by :user_name,
          :map => "function(doc) {
                if ((doc['couchrest-type'] == 'User') && doc['user_name'])
                {
                     emit(doc['user_name'],doc);
                }
          }"
  view_by :full_name,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'User') && doc['full_name'])
             {
                emit(doc['full_name'],doc);
             }
          }"

  view_by :user_name_filter_view,
          :map => "function(doc) {
                if ((doc['couchrest-type'] == 'User') && doc['user_name'])
                {
                    emit(['all',doc['user_name']],doc);
                    if(doc['disabled'] == 'false')
                      emit(['active',doc['user_name']],doc);
                }
          }"
  view_by :full_name_filter_view,
          :map => "function(doc) {
              if ((doc['couchrest-type'] == 'User') && doc['full_name'])
             {
                emit(['all',doc['full_name']],doc);
                if(doc['disabled'] == 'false')
                  emit(['active',doc['full_name']],doc);

             }
          }"

  view_by :unverified,
          :map => "function(doc) {
              if (doc['couchrest-type'] == 'User' && (doc['verified'] == false || doc['verified'] == 'false'))
             {
                emit(doc);
             }
             }"


  before_save :make_user_name_lowercase, :encrypt_password
  after_save :save_devices


  before_update :if => :disabled? do |user|
    Session.delete_for user
  end

  validates_presence_of :full_name, :message => I18n.t("models.user.validation.error_message.full_name")
  validates_presence_of :password_confirmation, :message => I18n.t("models.user.validation.error_message.password_confirmation"), :if => :password_required?
  validates_presence_of :role_ids, :message => I18n.t("models.user.validation.error_message.role_ids"), :if => Proc.new {|user| user.verified}
  validates_presence_of :organisation, :message => I18n.t("models.user.validation.error_message.organisation")

  validates_format_of :user_name, :with => /^[^ ]+$/, :message => I18n.t("models.user.validation.error_message.user_name")

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/, :if => :email_entered?,
                      :message => I18n.t("models.user.validation.error_message.email")

  validates_confirmation_of :password, :if => :password_required? && :password_confirmation_entered?
  validates_with_method :user_name, :method => :is_user_name_unique


  def self.all_unverified
    User.by_unverified
  end

  def self.find_by_user_name(user_name)
    User.by_user_name(:key => user_name.downcase).first
  end

  def initialize args={}
    self["mobile_login_history"] = []
    super args
  end

  def email_entered?
    !email.blank?
  end

  def is_user_name_unique
    user = User.find_by_user_name(user_name)
    return true if user.nil? or self.id == user.id
    [false, I18n.t("models.user.validation.error_message.user_name_uniqueness")]
  end

  def authenticate(check)
    if new?
      raise Exception.new, I18n.t("models.user.validation.error_message.authenticate")
    end
    !disabled? && crypted_password == self.class.encrypt(check, self.salt)
  end

  def roles
    @roles ||= role_ids.collect { |id| Role.get(id) }.flatten
  end

  def has_permission?(permission)
    permissions && permissions.include?(permission)
  end

  def has_any_permission?(*any_of_permissions)
    (any_of_permissions.flatten - permissions).count < any_of_permissions.flatten.count
  end

  def permissions
    roles.compact.collect(&:permissions).flatten
  end

  def add_mobile_login_event imei, mobile_number
    self.mobile_login_history << MobileLoginEvent.new(:imei => imei, :mobile_number => mobile_number)

    if (Device.all.none? { |device| device.imei == imei })
      device = Device.new(:imei => imei, :blacklisted => false, :user_name => self.user_name)
      device.save!
    end
  end

  def devices
    Device.all.select { |device| device.user_name == self.user_name }
  end

  def devices= device_hashes
    all_devices = Device.all
    @devices = device_hashes.map do |device_hash|
      device = all_devices.detect { |device| device.imei == device_hash["imei"] }
      device.blacklisted = device_hash["blacklisted"] == "true"
      device
    end
  end

  def localize_date(date_time, format = "%d %B %Y at %H:%M (%Z)")
    DateTime.parse(date_time).in_time_zone(self[:time_zone]).strftime(format)
  end

  def has_role_ids?(attributes)
    ADMIN_ASSIGNABLE_ATTRIBUTES.any? { |e| attributes.keys.include? e }
  end

  private

  def save_devices
    @devices.map(&:save!) if @devices
    true
  end

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Clock.now.to_s}--#{self.user_name}--") if new_record?
    self.crypted_password = self.class.encrypt(password, salt)
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def password_required?
    crypted_password.blank? || !password.blank? || !password_confirmation.blank?
  end

  def password_confirmation_entered?
    !password_confirmation.blank?
  end

  def make_user_name_lowercase
    user_name.downcase!
  end

end
