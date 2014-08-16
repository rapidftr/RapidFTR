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
        /the home\s?page/                              => Proc.new { |options,matches| '/' },
        /the new create_custom_field page/             => Proc.new { |options,matches| new_create_custom_field_path },
        /the new assign_unique_id_to_a_child page/     => Proc.new { |options,matches| new_assign_unique_id_to_a_child_path(options) },
        /add child page/                               => Proc.new { |options,matches| new_child_path(options) },
        /new child page/                               => Proc.new { |options,matches| new_child_path(options) },
        /children listing page/                        => Proc.new { |options,matches| children_path(options) },
        /children display page/                        => Proc.new { |options,matches| },
        /saved record page for child with name "(.+)"/ => Proc.new { |options,matches| child_name = matches[1]; child = Child.by_name(:key                                                                                              => child_name); raise "no child named '#{child_name}'" if child.nil? || child.empty?; child_path(child.first, options) },
        /child record page for "(.+)"/                 => Proc.new { |options,matches| child_name = matches[1]; child = Child.by_name(:key                                                                                              => child_name); raise "no child named '#{child_name}'" if child.nil? || child.empty?; child_path(child.first, options) },
        /child record page for unique id "(.+)"/       => Proc.new { |options,matches| unique_id = matches[1]; child = Child.get unique_id; rails "no child with unique id '#{unique_id}'" if child.nil?; child_path(child, options) },
        /change log page for "(.+)"/                   => Proc.new { |options,matches| child_name = matches[1]; child = Child.by_name(:key                                                                                              => child_name); raise "no child named '#{child_name}'" if child.nil? || child.empty?; child_history_path(child.first, options) },
        /new user page/                                => Proc.new { |options,matches| new_user_path(options) },
        /manage users page/                            => Proc.new { |options,matches| users_path(options) },
        /edit user page for "(.+)"/                    => Proc.new { |options,matches| user = User.find_by_user_name(matches[1]); edit_user_path(user, options) },
        /user details page for "(.+)"/                 => Proc.new { |options,matches| user = User.find_by_user_name(matches[1]); user_path(user, options) },
        /child search page/                            => Proc.new { |options,matches| search_children_path(options) },
        /child advanced search page/                   => Proc.new { |options,matches| advanced_search_index_path(options) },
        /login page/                                   => Proc.new { |options,matches| login_path(options) },
        /logout page/                                  => Proc.new { |options,matches| logout_path(options) },
        /child search results page/                    => Proc.new { |options,matches| search_children_path(options) },
        /child advanced search results page/           => Proc.new { |options,matches| advanced_search_index_path(options) },
        /edit form section page for "(.+)"$/           => Proc.new { |options,matches| edit_form_section_path(:id                                                                                                                       => matches[1]) },
        /edit field page for "(.+)" on "(.+)" form$/   => Proc.new { |options,matches| edit_form_section_field_path(:form_section_id                                                                                                    => matches[2], :id                                                                                                                => matches[1]) },
        /form section page/                            => Proc.new { |options,matches| form_sections_path(options) },
        /choose field type page/                       => Proc.new { |options,matches| arbitrary_form_section = FormSection.new; new_form_section_field_path(arbitrary_form_section, options) },
        /the edit user page for "(.+)"$/               => Proc.new { |options,matches| user = User.by_user_name(:key                                                                                                                    => matches[1]); raise "no user named #{matches[1]}" if user.nil?; edit_user_path(user) },
        /new field page for "(.+)" for form "(.+)"/    => Proc.new { |options,matches| field_type = matches[1]; form_section_id = matches[2]; new_form_section_field_path(:form_section_id                                              => form_section_id,  :type                                                                                                        => field_type) },
        /the edit form section page for "(.+)"/        => Proc.new { |options,matches| form_section = matches[1]; form_section_fields_path(form_section) },
        /the admin page/                               => Proc.new { |options,matches| admin_path(options) },
        /system settings page/                         => Proc.new { |options,matches| admin_path(options) },
        /system users page/                            => Proc.new { |options,matches| system_users_path },
        /all child Ids/                                => Proc.new { |options,matches| child_ids_path },
        /the child listing filtered by (.+)/           => Proc.new { |options,matches| child_filter_path(:filter                                                                                                                        => matches[1]) },
        /duplicate child page for "(.+)"$/             => Proc.new { |options,matches| child = Child.by_name(:key                                                                                                                       => matches[1]).first; new_child_duplicate_path(child) },
        /create role page/                             => Proc.new { |options,matches| new_role_path },
        /roles index page/                             => Proc.new { |options,matches| roles_path },
        /devices listing page/                         => Proc.new { |options,matches| devices_path },
        /replications page/                            => Proc.new { |options,matches| replications_path },
        /reports page/                                 => Proc.new { |options,matches| reports_path },
        /the form sections page for "(.*)"/            => Proc.new { |options,matches| form_form_sections_path(Form.by_name.key(matches[1]).first) },
        /forms page/                                   => Proc.new { |options,matches| forms_path },
        /standard form page/                           => Proc.new { |options,matches| standard_forms_path }
      }
    end
    @@regex_to_path_map
  end

  def path_to(page_name, options = {})
    format = page_name[/^(?:|the )(\w+) formatted/, 1]
    options.reverse_merge!(:format => format)
    path_for_cuke_string(page_name, options) || raise("Can't find mapping from \"#{page_name}\" to a path.\nNow, go and add a mapping in #{__FILE__}")
  end

  def path_for_cuke_string string_to_match, options={}
    our_key, our_proc = path_map.find { |key,value| key.match(string_to_match) }
    return our_proc.call options, our_key.match(string_to_match)
  end
end

World(NavigationHelpers)
