require 'digest/sha2'
require 'permission_levels'

class User < CouchRestRails::Document
  use_database :user
  include CouchRest::Validation

  property :full_name
  property :user_name
  property :crypted_password
  property :salt
  property :user_type
  property :phone
  property :email
  property :organisation
  property :position
  property :location
  property :permission_level
  property :disabled, :cast_as => :boolean
  property :mobile_login_history, :cast_as => ['MobileLoginEvent']
  property :time_zone, :default => "UTC"
  attr_accessor :password_confirmation, :password


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


  before_save :make_user_name_lowercase, :encrypt_password
  after_save :save_devices


  before_update :if => :disabled? do |user|
    Session.delete_for user
  end

  validates_presence_of :full_name,:message=>"Please enter full name of the user"
  validates_presence_of :user_type,:message=>"Please choose a user type"
  validates_presence_of :password_confirmation, :message=>"Please enter password confirmation", :if => :password_required?


  validates_format_of :user_name,:with => /^[^ ]+$/, :message=>"Please enter a valid user name"
  validates_format_of :password,:with => /^[^ ]+$/, :message=>"Please enter a valid password", :if => :new?

  validates_format_of :email, :as => :email_address, :if => :email_entered?

  validates_format_of :email, :with =>  /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/, :if => :email_entered?,
                      :message =>"Please enter a valid email address"


  validates_confirmation_of :password, :if => :password_required?
  validates_with_method   :user_name, :method => :is_user_name_unique

  validates_presence_of :permission_level, :message => "Please select a permission level"
  validates_with_method :permission_level, :method => :is_permission_level_valid

  def self.find_by_user_name(user_name)
     User.by_user_name(:key => user_name.downcase).first
  end

  def initialize args={}
    self["mobile_login_history"] = []
    args.reverse_merge!(:permission_level => PermissionLevel::LIMITED)
    super args
  end

  def email_entered?
    !email.blank?
  end

  def authenticate(check)
    if new?
      raise Exception.new, "Can't authenticate a un-saved user"
    end
    !disabled? && crypted_password == encrypt(check)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def make_admin
    self.user_type = "Administrator"
  end

  def add_mobile_login_event imei, mobile_number
    self.mobile_login_history << MobileLoginEvent.new(:imei => imei, :mobile_number => mobile_number)

    if (Device.all.none? {|device| device.imei == imei})
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

  def localize_date(date_time)
    DateTime.parse(date_time).in_time_zone(self[:time_zone]).strftime("%d %B %Y at %H:%M (%Z)")
  end

  private
  def is_user_name_unique
    user = User.find_by_user_name(user_name)
    return true if user.nil? or self.id == user.id
    [false, "User name has already been taken! Please select a new User name"]
  end

  def is_permission_level_valid
    PermissionLevel.valid? permission_level
  end

  def save_devices
    @devices.map(&:save!) if @devices
    true
  end


  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.user_name}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def password_required?
    crypted_password.blank? || !password.blank? || !password_confirmation.blank?
  end

  def make_user_name_lowercase
    user_name.downcase!
  end

end
