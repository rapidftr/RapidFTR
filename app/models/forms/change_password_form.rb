module Forms

  class ChangePasswordForm
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :user, :old_password, :new_password, :new_password_confirmation

    validates :old_password, :presence => true

    def initialize(attributes={})
      attributes.each do |name, value|
        send "#{name}=", value
      end
    end


    def persisted?
      false
    end
  end

end