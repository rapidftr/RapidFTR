require 'digest/sha2'
class User < CouchRestRails::Document
  use_database :user
  include CouchRest::Validation

  property :full_name
  property :user_name
  property :crypted_password
  property :salt
  property :user_type
  property :email
  property :organisation
  property :position
  property :location
  property :disabled, :cast_as => :boolean
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
  
  before_update :if => :disabled? do |user|
    Session.delete_for user
  end
  before_validate :auto_fill_password_confirmation_if_not_supplied

  validates_presence_of :full_name,:message=>"Please enter full name of the user"
  validates_presence_of :user_type,:message=>"Please choose a user type"


  validates_format_of :user_name,:with => /^[^ ]+$/, :message=>"Please enter a valid user name"
  validates_format_of :password,:with => /^[^ ]+$/, :message=>"Please enter a valid password", :if => :new?
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
                      :message =>"Please enter a valid email address"

  validates_confirmation_of :password, :if => :password_required?
  validates_with_method   :user_name, :method => :is_user_name_unique


  def self.find_by_user_name(user_name)
     User.by_user_name(:key => user_name.downcase).first
  end

  def is_user_name_unique
    user = User.find_by_user_name(user_name)
    return true if user.nil? or self.id == user.id
    [false, "User name has already been taken! Please select a new User name"]
  end

  def authenticate(check)
    if new? 
      raise Exception.new, "Can't authenticate a un-saved user"
    end
    !disabled && crypted_password == encrypt(check)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  private

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.user_name}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def make_user_name_lowercase
     user_name.downcase!
  end

  def auto_fill_password_confirmation_if_not_supplied
    self.password_confirmation = password if self.password_confirmation.nil?
  end

end
