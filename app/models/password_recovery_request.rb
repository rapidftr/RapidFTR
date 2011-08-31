class PasswordRecoveryRequest < CouchRestRails::Document
  use_database :password_recovery_request

  include CouchRest::Validation

  property :user_name
  property :hidden, :cast_as => :boolean, :default => false

  timestamps!

  validates_presence_of :user_name

  def ==(other)
    user_name == other.user_name
  end

  def hide!
    self.hidden = true
    save
  end

  def self.to_display
    PasswordRecoveryRequest.all.select { |request| request.hidden == false }
  end
end
