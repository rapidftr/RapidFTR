module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb

  @@regex_to_path_map = {}

  def path_map
    if @@regex_to_path_map.empty?
      self.class.send :include, Rails.application.routes.url_helpers
      @@regex_to_path_map = {
        /the home\s?page/                              => proc { |_options, _matches| '/' },
        /the new create_custom_field page/             => proc { |_options, _matches| new_create_custom_field_path },
        /the new assign_unique_id_to_a_child page/     => proc { |options, _matches| new_assign_unique_id_to_a_child_path(options) },
        /add child page/                               => proc { |options, _matches| new_child_path(options) },
        /new child page/                               => proc { |options, _matches| new_child_path(options) },
        /children listing page/                        => proc { |options, _matches| children_path(options) },
        /children display page/                        => proc { |_options, _matches| },
        /saved record page for child with name "(.+)"/ => proc do |options, matches|
                                                            child_name = matches[1]
                                                            child = Child.by_name(:key => child_name)
                                                            fail "no child named '#{child_name}'" if child.nil? || child.empty?
                                                            child_path(child.first, options)
                                                          end,
        /child record page for "(.+)"/                 => proc do |options, matches|
                                                            child_name = matches[1]
                                                            child = Child.by_name(:key => child_name)
                                                            fail "no child named '#{child_name}'" if child.nil? || child.empty?
                                                            child_path(child.first, options)
                                                          end,
        /child record page for unique id "(.+)"/       => proc do |options, matches|
                                                            unique_id = matches[1]
                                                            child = Child.get unique_id
                                                            fail "no child with unique id '#{unique_id}'" if child.nil?
                                                            child_path(child, options)
                                                          end,
        /change log page for "(.+)"/                   => proc do |options, matches|
                                                            child_name = matches[1]
                                                            child = Child.by_name(:key => child_name)
                                                            fail "no child named '#{child_name}'" if child.nil? || child.empty?
                                                            child_history_path(child.first, options)
                                                          end,
        /new user page/                                => proc { |options, _matches| new_user_path(options) },
        /manage users page/                            => proc { |options, _matches| users_path(options) },
        /edit user page for "(.+)"/                    => proc do |options, matches|
                                                            user = User.find_by_user_name(matches[1])
                                                            edit_user_path(user, options)
                                                          end,
        /user details page for "(.+)"/                 => proc do |options, matches|
                                                            user = User.find_by_user_name(matches[1])
                                                            user_path(user, options)
                                                          end,
        /child search page/                            => proc { |options, _matches| search_children_path(options) },
        /child advanced search page/                   => proc { |options, _matches| advanced_search_index_path(options) },
        /login page/                                   => proc { |options, _matches| login_path(options) },
        /logout page/                                  => proc { |options, _matches| logout_path(options) },
        /child search results page/                    => proc { |options, _matches| search_children_path(options) },
        /child advanced search results page/           => proc { |options, _matches| advanced_search_index_path(options) },
        /edit form section page for "(.+)"$/           => proc { |_options, matches| edit_form_section_path(:id => matches[1]) },
        /edit field page for "(.+)" on "(.+)" form$/   => proc { |_options, matches| edit_form_section_field_path(:form_section_id => matches[2], :id => matches[1]) },
        /form section page/                            => proc { |options, _matches| form_sections_path(options) },
        /choose field type page/                       => proc do |options, _matches|
                                                            arbitrary_form_section = FormSection.new
                                                            new_form_section_field_path(arbitrary_form_section, options)
                                                          end,
        /the edit user page for "(.+)"$/               => proc do |_options, matches|
                                                            user = User.by_user_name(:key => matches[1])
                                                            fail "no user named #{matches[1]}" if user.nil?
                                                            edit_user_path(user)
                                                          end,
        /new field page for "(.+)" for form "(.+)"/    => proc do |_options, matches|
                                                            field_type = matches[1]
                                                            form_section_id = matches[2]
                                                            new_form_section_field_path(:form_section_id => form_section_id, :type => field_type)
                                                          end,
        /the edit form section page for "(.+)"/        => proc do |_options, matches|
                                                            form_section = matches[1]
                                                            form_section_fields_path(form_section)
                                                          end,
        /the admin page/                               => proc { |options, _matches| admin_path(options) },
        /system settings page/                         => proc { |options, _matches| admin_path(options) },
        /system users page/                            => proc { |_options, _matches| system_users_path },
        /all child Ids/                                => proc { |_options, _matches| child_ids_path },
        /the child listing filtered by (.+)/           => proc { |_options, matches| child_filter_path(:filter => matches[1]) },
        /duplicate child page for "(.+)"$/             => proc do |_options, matches|
                                                            child = Child.by_name(:key => matches[1]).first
                                                            new_child_duplicate_path(child)
                                                          end,
        /create role page/                             => proc { |_options, _matches| new_role_path },
        /roles index page/                             => proc { |_options, _matches| roles_path },
        /devices listing page/                         => proc { |_options, _matches| devices_path },
        /replications page/                            => proc { |_options, _matches| replications_path },
        /reports page/                                 => proc { |_options, _matches| reports_path },
        /the form sections page for "(.*)"/            => proc { |_options, matches| form_form_sections_path(Form.by_name.key(matches[1]).first) },
        /forms page/                                   => proc { |_options, _matches| forms_path },
        /standard form page/                           => proc { |_options, _matches| standard_forms_path },
        /enquiries listing page/                       => proc { |_options, _matches| enquiries_path }

      }
    end
    @@regex_to_path_map
  end

  def path_to(page_name, options = {})
    format = page_name[/^(?:|the )(\w+) formatted/, 1]
    options.reverse_merge!(:format => format)
    path_for_cuke_string(page_name, options) || fail("Can't find mapping from \"#{page_name}\" to a path.\nNow, go and add a mapping in #{__FILE__}")
  end

  def path_for_cuke_string(string_to_match, options = {})
    our_key, our_proc = path_map.find { |key, _value| key.match(string_to_match) }
    our_proc.call options, our_key.match(string_to_match)
  end
end

World(NavigationHelpers)
