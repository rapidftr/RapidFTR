module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

      when /the home\s?page/
        '/'
    when /the new assign_unique_id_to_a_child page/
      new_assign_unique_id_to_a_child_path


      when /new child page/
        new_child_path

      when /children listing page/
        children_path

      when /saved record page/

          when /new user page/
        new_user_path

      when /manage users page/
        users_path



        
        


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
