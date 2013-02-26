module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, options = {})

    format = page_name[/^(?:|the )(\w+) formatted/, 1]
    options.reverse_merge!(:format => format)

    case page_name

      when /the home\s?page/
        '/'
      when /the new create_custom_field page/
        new_create_custom_field_path

      when /the new add_suggested_field_to_form_section page/
        new_add_suggested_field_to_form_section_path

      when /the new assign_unique_id_to_a_child page/
        new_assign_unique_id_to_a_child_path(options)

      when /add child page/
        new_child_path(options)

      when /new child page/
        new_child_path(options)

      when /children listing page/
        children_path(options)

      when /saved record page for child with name "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil?
        child_path(child, options)

      when /child record page for "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil?
        child_path(child, options)

      when /change log page for "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil?
        child_history_path(child, options)

      when /new user page/
        new_user_path(options)

      when /manage users page/
        users_path(options)

      when /edit user page for "(.+)"/
        user = User.find_by_user_name($1)
        edit_user_path(user, options)

      when /user details page for "(.+)"/
        user = User.find_by_user_name($1)
        user_path(user, options)


      when /child search page/
        search_children_path(options)

      when /child advanced search page/
        new_advanced_search_path(options)

      when /login page/
        login_path(options)

      when /logout page/
        logout_path(options)

      when /child search results page/
        search_children_path(options)

      when /child advanced search results page/
        advanced_search_index_path(options)

      when /create form section page/
        new_form_section_path(options)

      when /edit form section page for "(.+)"$/
        edit_form_section_path(:id => $1)

      when /edit field page for "(.+)" on "(.+)" form$/
        edit_form_section_field_path(:form_section_id => $2, :id => $1)

      when /form section page/
        form_sections_path(options)

      when /choose field type page/
        arbitrary_form_section = FormSection.new
        new_form_section_field_path(arbitrary_form_section, options)

      when /the edit user page for "(.+)"$/
        user = User.by_user_name(:key => $1)
        raise "no user named #{$1}" if user.nil?
        edit_user_path(user)

      when /new field page for "(.+)" for form "(.+)"/
        field_type = $1
        form_section_id = $2
        new_form_section_field_path(:form_section_id => form_section_id,  :type => field_type)

      when /the edit form section page for "(.+)"/
        form_section = $1
        form_section_fields_path(form_section)

      when /the admin page/
        admin_path(options)

      when /system settings page/
        admin_path(options)

      when /system users page/
        system_users_path

      when /the edit administrator contact information page/
        edit_contact_information_path(:administrator)
      when /(the )?administrator contact page/
        contact_information_path(:administrator, options)

      when /all child Ids/
        child_ids_path

      when /the child listing filtered by (.+)/
        child_filter_path (:filter => $1)

      when /duplicate child page for "(.+)"$/
        child = Child.by_name(:key => $1).first
        new_child_duplicate_path(child)

      when /create role page/
        new_role_path

      when /roles index page/
        roles_path

      when /devices listing page/
        devices_path

      when /replications page/
        replications_path

      when /reports page/
        reports_path


      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
