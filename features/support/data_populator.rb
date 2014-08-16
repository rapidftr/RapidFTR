class DataPopulator

  def create_user_with_permission(permission)
    create_user('default_username', 'default_password', permission)
  end

  def create_user(username, password='radpiftr', permission=nil)
    user_type = 'user'
    create_account(user_type, username, password, permission)
  end

  def create_admin(username, password, permission)
    user_type = 'admin'
    create_account(user_type, username, password, permission)
  end

  def create_senior_official(username, password, permission)
    user_type = 'senior official'
    create_account(user_type, username, password, permission)
  end

  def create_registration_worker(username, password, permission)
    user_type = 'registration worker'
    create_account(user_type, username, password, permission)
  end

  def ensure_user_exists(user_name)
    user = User.find_by_user_name(user_name)
    if user.nil?
      user = create_user(user_name)
    end
    user
  end

  private

  def create_account(user_type, username, password, permission)
    permissions = []
    permissions.push(Permission.all_permissions) if user_type.downcase == "admin" and permission.nil?
    permissions.push(Permission::CHILDREN[:register]) if user_type.downcase == "user" and permission.nil?
    permissions.push(Permission::REPORTS[:view]) if user_type.downcase == "senior official" and permission.nil?
    permissions.push(Permission::CHILDREN[:edit], Permission::CHILDREN[:register], Permission::CHILDREN[:view_and_search], Permission::ENQUIRIES[:create], Permission::ENQUIRIES[:update]) if user_type.downcase == "registration worker" and permission.nil?
    permissions.push(Permission.all_permissions) if permission.to_s.downcase.split(',').include?('admin')
    permissions.push(permission.split(",")) if permission
    permissions.flatten!

    role_name = permissions.join("-")
    role = Role.find_by_name(role_name) || Role.create(:name => role_name, :permissions => permissions)

    @user = User.find_by_user_name(username)

    if @user.nil?
      @user = User.new(
          :user_name=>username,
          :password=>password,
          :password_confirmation=>password,
          :full_name=>username,
          :organisation=>"UNICEF",
          :disabled => "false",
          :email=>"#{username}@test.com",
          :role_ids => [role.id]
      )
      @user.save!
    end
    @user
  end
end
