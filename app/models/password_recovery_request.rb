class PasswordRecoveryRequest < CouchRest::Model::Base
  use_database :password_recovery_request

  property :user_name
  property :hidden, TrueClass, :default => false

  timestamps!

  validates_presence_of :user_name

  def hide!
    self.hidden = true
    save
  end

  def self.to_display
    PasswordRecoveryRequest.all.select { |request| request.hidden == false }
  end
end
