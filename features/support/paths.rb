module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, options = {})

    format = page_name[/^(?:|the )(\w+) formatted/,1]
    options.reverse_merge!( :format => format )

    case page_name

      when /the home\s?page/
        '/'
      when /the new assign_unique_id_to_a_child page/
        new_assign_unique_id_to_a_child_path(options)


      when /new child page/
        new_child_path(options)

      when /children listing page/
        children_path(options)

      when /saved record page for child with name "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil? || child == []
        child_path( child, options )

      when /full url for child with name "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil? || child == []
        child_url( child, options )

      when /new user page/
        new_user_path(options)

      when /manage users page/
        users_path(options)

      when /edit user page for "(.+)"/
        user = User.find_by_user_name($1)
        edit_user_path(user, options)

      when /child search page/
        search_children_path(options)
        
      when /login page/
        login_path(options)
        
      when /logout page/
        logout_path(options)
        
      when /child search results page/
        search_children_path(options)



      when /photo resource for child with name "(.+)"/
        child_name = $1
        child = Summary.by_name(:key => child_name)
        raise "no child named '#{child_name}'" if child.nil?
        child_path( child, :format => 'jpg' )


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
