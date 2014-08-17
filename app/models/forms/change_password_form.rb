module Forms

  class ChangePasswordForm
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :user, :old_password, :new_password, :new_password_confirmation

    validates :user, :presence => true
    validates :old_password, :presence => true
    validates :new_password, :presence => true, :confirmation => true
    validates :new_password_confirmation, :presence => true
    validate :check_old_password

    def initialize(attributes = {})
      attributes.each do |name, value|
        send "#{name}=", value
      end
    end

    def check_old_password
      if user.crypted_password != User.encrypt(old_password, user.salt)
        errors[:old_password] = I18n.t("user.messages.passwords_do_not_match")
        return false
      else
        return true
      end
    end

    def reset
      self.old_password = ''
      self.new_password = ''
      self.new_password_confirmation = ''
    end

    def execute
      if valid?
        user.password = new_password
        user.password_confirmation = new_password_confirmation
        user.save
      else
        reset
        false
      end
    end

    def persisted?
      false
    end
  end

end
