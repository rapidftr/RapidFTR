require 'digest/sha2'
class User < CouchRestRails::Document
  use_database :user
  include CouchRest::Validation

  property :full_name
  property :user_name
  property :password
  property :user_type
  property :email
  property :organisation
  property :position
  property :location
  attr_accessor :password_confirmation

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


  before_save :make_user_name_lowercase
  before_validate :auto_fill_password_confirmation_if_not_supplied

  validates_presence_of :full_name,:message=>"Please enter full name of the user"
  validates_presence_of :user_type,:message=>"Please choose a user type"


  validates_format_of :user_name,:with => /^[^ ]+$/, :message=>"Please enter a valid user name"
  validates_format_of :password,:with => /^[^ ]+$/, :message=>"Please enter a valid password"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
                      :message =>"Please enter a valid email address"

  validates_confirmation_of :password
  validates_with_method   :user_name, :method => :is_user_name_unique


  def self.find_by_user_name(user_name)
     User.by_user_name(:key => user_name.downcase).first
  end

  def is_user_name_unique

    user = User.find_by_user_name(user_name)
    if  user.nil?
      true
    else
      return true if self.id == user.id
      [false, "User name has already been taken! Please select a new User name"]
    end
  end

  def autheticate(check)
    password == check
  end

  private
  def make_user_name_lowercase
     user_name.downcase!
  end

  def auto_fill_password_confirmation_if_not_supplied
    self.password_confirmation = password if self.password_confirmation.nil?
  end

end
