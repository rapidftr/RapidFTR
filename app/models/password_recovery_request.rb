class PasswordRecoveryRequest < CouchRestRails::Document
  use_database :password_recovery_request

  include CouchRest::Validation

  property :user_name

  validates_presence_of :user_name

end
