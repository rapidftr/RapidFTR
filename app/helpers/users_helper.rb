module UsersHelper
  def editing_ourself?(editable_user)
    !editable_user.new_record? && current_user_name == editable_user.user_name
  end
end
