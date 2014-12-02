require 'digest/sha2'
class User < CouchRest::Model::Base
  use_database :user

  include RapidFTR::Model
  include RapidFTR::CouchRestRailsBackward

  property :full_name
  property :user_name
  property :verified, TrueClass, :default => true
  property :crypted_password
  property :salt

  property :phone
  property :email
  property :organisation
  property :position
  property :location
  property :disabled, TrueClass, :default => false
  property :mobile_login_history, [MobileLoginEvent]
  property :role_ids, :type => [String]
  property :time_zone, :default => 'UTC'
  property :locale

  property :share_contact_info, TrueClass, :default => false
  property :force_password_change, TrueClass, :default => false

  attr_accessor :password_confirmation, :password
  ADMIN_ASSIGNABLE_ATTRIBUTES = [:role_ids]

  timestamps!

  design do

    view :by_user_name

    view :by_full_name,
         :map => "function(doc) {
             if ((doc['couchrest-type'] == 'User') && doc['full_name'])
             {
               emit(doc['full_name'],doc);
             }
         }"

    view :by_user_name_filter_view,
         :map => "function(doc) {
               if ((doc['couchrest-type'] == 'User') && doc['user_name'])
               {
                   emit(['all',doc['user_name']],doc);
                   if(doc['disabled'] == 'false' || doc['disabled'] == false)
                     emit(['active',doc['user_name']],doc);
               }
         }"
    view :by_full_name_filter_view,
         :map => "function(doc) {
             if ((doc['couchrest-type'] == 'User') && doc['full_name'])
             {
               emit(['all',doc['full_name']],doc);
               if(doc['disabled'] == 'false' || doc['disabled'] == false)
                 emit(['active',doc['full_name']],doc);

             }
         }"

    view :by_unverified,
         :map => "function(doc) {
             if (doc['couchrest-type'] == 'User' && (doc['verified'] == false || doc['verified'] == 'false'))
              {
                 emit(doc);
              }
          }"

    view :by_share_contact_info,
         :map => "function(doc) {
             if (doc['couchrest-type'] == 'User'
                     && doc['share_contact_info']
                     && doc['verified']
                     && !doc['disabled']) {
                 emit(doc);
              }
          }"
  end

  before_save :make_user_name_lowercase, :encrypt_password
  after_save :save_devices

  before_update :if => :disabled? do |user|
    Session.delete_for user
  end

  validates :full_name, :presence => {:message => I18n.t('errors.models.user.full_name')}
  validates :password_confirmation, :presence => {:message => I18n.t('errors.models.user.password_confirmation'), :if => :password_required?}
  validates :role_ids, :presence => {:message => I18n.t('errors.models.user.role_ids'), :if => proc { |user| user.verified }}
  validates :organisation, :presence => {:message => I18n.t('errors.models.user.organisation')}

  validates :user_name, :format => {:with => /\A[^ ]+\z/, :message => I18n.t('errors.models.user.user_name')}

  validates :email, :format => {:with => /\A([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$\z/,
                                :if => :email_entered?,
                                :message => I18n.t('errors.models.user.email')}

  validates :password, :confirmation => {:if => :password_required? && :password_confirmation_entered?,
                                         :message => I18n.t('errors.models.user.password_mismatch')}

  # FIXME: 409s randomly...destroying user records before test as a temp
  validate :unique_user_name

  before_save :generate_id

  @current_user = nil

  class << self
    attr_accessor :current_user
  end

  # In order to track changes on attributes declared as attr_accessor and
  # trigger the callbacks we need to use attribute_will_change! method.
  # check lib/couchrest/model/extended_attachments.rb in source code.
  # So, override the method for password in order to track changes.
  def password=(value)
    attribute_will_change!('password') if use_dirty? && @password != value
    @password = value
  end

  attr_reader :password

  def self.all_unverified
    User.by_unverified
  end

  def self.find_by_user_name(user_name)
    User.by_user_name(:key => user_name.downcase).first
  end

  def initialize(args = {}, args1 = {})
    self['mobile_login_history'] = []
    super args, args1
  end

  def email_entered?
    !email.blank?
  end

  def unique_user_name
    user = User.find_by_user_name(user_name)
    return true if user.nil? || id == user.id
    errors.add(:user_name, I18n.t('errors.models.user.user_name_uniqueness'))
  end

  def authenticate(check)
    if new?
      fail Exception.new, I18n.t('errors.models.user.authenticate')
    end
    !disabled? && crypted_password == self.class.encrypt(check, salt)
  end

  def roles
    @roles ||= role_ids.map { |id| Role.get(id) }.flatten
  end

  def has_permission?(permission)
    permissions && permissions.include?(permission)
  end

  def has_any_permission?(*any_of_permissions)
    (any_of_permissions.flatten - permissions).count < any_of_permissions.flatten.count
  end

  def permissions
    roles.compact.map(&:permissions).flatten
  end

  def add_mobile_login_event(imei, mobile_number)
    mobile_login_history << MobileLoginEvent.new(:imei => imei, :mobile_number => mobile_number)

    if Device.all.none? { |device| device.imei == imei }
      device = Device.new(:imei => imei, :blacklisted => false, :user_name => user_name)
      device.save!
    end
  end

  def devices
    Device.all.select { |device| device.user_name == user_name }
  end

  def devices=(device_hashes)
    all_devices = Device.all
    # attr_accessor devices field change.
    attribute_will_change!('devices')
    @devices = device_hashes.map do |device_hash|
      device = all_devices.find { |d| d.imei == device_hash['imei'] }
      device.blacklisted = device_hash['blacklisted'] == 'true'
      device
    end
  end

  def localize_date(date_time, format = '%d %B %Y at %H:%M (%Z)')
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
    self.salt = Digest::SHA1.hexdigest("--#{Clock.now}--#{user_name}--") if new_record?
    new_crypted_password = self.class.encrypt(password, salt)
    if !new_record? && new_crypted_password != crypted_password
      self.force_password_change = false
    end
    self.crypted_password = new_crypted_password
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

  def generate_id
    self['_id'] ||= "user-#{user_name}".parameterize.dasherize
  end
end
