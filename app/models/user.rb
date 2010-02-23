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
                emit(doc['user_name'],doc.user_name);
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

  validates_presence_of :full_name,:message=>"Please enter full name of the user"
  validates_presence_of :user_type,:message=>"Please choose a user type"


  validates_format_of :user_name,:with => /^[^ ]+$/, :message=>"Please enter a valid user name"
  validates_format_of :password,:with => /^[^ ]+$/, :message=>"Please enter a valid password"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/,
                      :message =>"Please enter a valid email address"

  validates_confirmation_of   :password
  validates_with_method   :user_name, :method => :is_user_name_unique


  def is_user_name_unique
    db_user_name= User.by_user_name(:key => user_name.downcase)
    if db_user_name.blank? 
      true
    else
      [false, "User name has already been taken! Please select a new User name"]
    end
  end

  private
  def make_user_name_lowercase
     user_name.downcase!
  end


#  def strip_off_white_spaces
#   user_name.gsub!(/ /,'');
#   password.gsub!(/ /,'');
#   password_confirmation.gsub!(/ /,'');
#  end

end
