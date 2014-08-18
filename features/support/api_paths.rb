module NavigationHelpers
  def self.included(base)
    base.send :include, Rails.application.routes.url_helpers
  end

  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def api_path_to(page_name, options = {})
    options.reverse_merge!(:format => 'json')

    case page_name

      when /the home\s?page/
        '/'
      when /the new create_custom_field page/
        new_create_custom_field_path

      when /the new assign_unique_id_to_a_child page/
        new_assign_unique_id_to_a_child_path(options)

      when /add child page/
        new_child_path(options)

      when /new child page/
        new_child_path(options)

      when /children listing page/
        api_children_path(options)

      when /saved record page for child with name "(.+)"/
        child_name = Regexp.last_match[1]
        child = Child.by_name(:key => child_name)
        fail "no child named '#{child_name}'" if child.nil? || child.empty?
        child_path(child.first, options)

      when /child record page for "(.+)"/
        child_name = Regexp.last_match[1]
        child = Child.by_name(:key => child_name)
        fail "no child named '#{child_name}'" if child.nil? || child.empty?
        child_path(child.first, options)

      when /change log page for "(.+)"/
        child_name = Regexp.last_match[1]
        child = Child.by_name(:key => child_name)
        fail "no child named '#{child_name}'" if child.nil? || child.empty?
        child_history_path(child.first, options)

      when /new user page/
        new_user_path(options)

      when /manage users page/
        users_path(options)

      when /edit user page for "(.+)"/
        user = User.find_by_user_name(Regexp.last_match[1])
        edit_user_path(user, options)

      when /child search page/
        search_children_path(options)

      when /child advanced search page/
        advanced_search_index_path(options)

      when /login page/
        login_path(options)

      when /logout page/
        logout_path(options)

      when /child search results page/
        search_children_path(options)

      when /child advanced search results page/
        advanced_search_index_path(options)

      when /edit form section page for "(.+)"$/
        edit_form_section_path(:id => Regexp.last_match[1])

      when /edit field page for "(.+)" on "(.+)" form$/
        edit_form_section_field_path(:form_section_id => Regexp.last_match[2], :id => Regexp.last_match[1])

      when /form section page/
        form_sections_path(options)

      when /choose field type page/
        arbitrary_form_section = FormSection.new
        new_form_section_field_path(arbitrary_form_section, options)

      when /the edit user page for "(.+)"$/
        user = User.by_user_name(:key => Regexp.last_match[1])
        fail "no user named #{Regexp.last_match[1]}" if user.nil?
        edit_user_path(user)

      when /new field page for "(.+)"/
        field_type = Regexp.last_match[1]
        new_form_section_field_path(:type => field_type)

      when /the edit form section page for "(.+)"/
        form_section = Regexp.last_match[1]
        form_section_fields_path(form_section)

      when /the admin page/
        admin_path(options)

      when /all child Ids/
        child_ids_path

      when /the child listing filtered by (.+)/
        child_filter_path Regexp.last_match[1]

      when /duplicate child page for "(.+)"$/
        child = Child.by_name(:key => Regexp.last_match[1]).first
        new_child_duplicate_path(child)

      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      else
        fail "Can't find mapping from \"#{page_name}\" to a path.\n" \
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
