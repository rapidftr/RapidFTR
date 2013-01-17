module Forms

  class ChangePasswordForm
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :user, :old_password, :new_password, :new_password_confirmation

    validates :user, :presence => true
    validates :old_password, :presence => true
    validates :new_password, :presence => true, :confirmation =>  true
    validates :new_password_confirmation, :presence => true
    validate :check_old_password

    def initialize(attributes={})
      attributes.each do |name, value|
        send "#{name}=", value
      end
    end

    def check_old_password
        if user.crypted_password != User.encrypt(old_password, user.salt)
          errors[:old_password] = "does not match current password"
          return false
        else
          return true
        end
    end


    def persisted?
      false
    end
  end

end