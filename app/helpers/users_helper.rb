module UsersHelper
  def editing_ourself?
    !edittable_user.new_record? && current_user_name == edittable_user.user_name
  end
end
