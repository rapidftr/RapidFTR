require 'spec_helper'

class Schema;
end

describe "children/show.html.erb" do

  describe "displaying a child's details"  do

    it "displays the Child's photo"

    it "renders all fields found on the FormSection" do

      form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
      form_section.add_field Field.new_text_field("age", "Age")
      form_section.add_field Field.new_radio_button("gender", ["male", "female"], "Gender")
      form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than"], "Date of separation")

      child = Child.new(:age => "27", :gender => "male", :date_of_separation => "1-2 weeks ago", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC")
      child.stub!(:has_one_interviewer?).and_return(true)

      user = User.new()

      assigns[:form_sections] = [form_section]
      assigns[:child] = child
      assigns[:user] = user

      render

      response.should have_tag(".section_name") do
        with_tag(".profile-section-label", /Age/)
        with_tag(".profile-section-label", /Gender/)
        with_tag(".profile-section-label", /Date of separation/)
      end

      response.should have_tag(".section_name .profile-section-value") do
        with_tag(".profile-section-value", "27")
        with_tag(".profile-section-value", "male")
        with_tag(".profile-section-value", "1-2 weeks ago")
      end
    end

    it "does not render fields found on a disabled FormSection" do

      form_section = FormSection.new :unique_id => "section_name", :enabled => "false"
      form_section.add_field Field.new_text_field("age")
      form_section.add_field Field.new_radio_button("gender", ["male", "female"])

      child = Child.new(:age => "27", :gender => "male", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC")
      child.stub!(:has_one_interviewer?).and_return(true)

      user = User.new()

      assigns[:form_sections] = [form_section]
      assigns[:child] = child
      assigns[:user] = user

      render

      response.should_not have_tag("dl.section_name dt")
    end

    describe "interviewer details" do
      it "should show registered by details and no link to change log if child has not been updated" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC")
        child.stub!(:has_one_interviewer?).and_return(true)

        user = User.new()

        user = User.new()

        assigns[:form_sections] = [form_section]
        assigns[:child] = child
        assigns[:user] = user

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should_not have_tag("#interviewer_details", /and others/)
        response.should_not have_tag("#interviewer_details", /Last updated:/)
      end

      it "should show link to change log if child has been updated by multiple people" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC", :last_updated_by => "jdoe", :last_updated_at => "July 20 2010 14:15:59UTC")
        child.stub!(:has_one_interviewer?).and_return(false)

        user = User.new()

        assigns[:form_sections] = [form_section]
        assigns[:child] = child
        assigns[:user] = user

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should have_tag("#interviewer_details", /and others/)
        response.should have_tag("#interviewer_details", /Last updated:/)
      end

      it "should not show link to change log if child was registered by and updated again by only the same person" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC", :last_updated_by => "jsmith", :last_updated_at => "July 20 2010 14:15:59UTC")
        child.stub!(:has_one_interviewer?).and_return(true)

        user = User.new()

        assigns[:form_sections] = [form_section]
        assigns[:child] = child
        assigns[:user] = user

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should_not have_tag("#interviewer_details", /and others/)
      end
   		it "should always show the posted at details when the record has been posted from a mobile client" do
					child = Child.new(:posted_at=> "2007-01-01 10:04pm", :posted_from=>"Mobile", :unique_id=>"bob", :_id=>"123123", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC")
      	  child.stub!(:has_one_interviewer?).and_return(true)
					form_section = FormSection.new :unique_id => "section_name", :enabled => "true"

          user = User.new()
        
        	assigns[:form_sections] = [form_section]
    	  	assigns[:child] = child
          assigns[:user] = user

       		render

        	response.should have_selector("#interviewer_details") do |fields|
          		fields[0].should contain("Posted from the mobile client at: 2007-01-01 10:04pm")
        	end 
			end
			it "should not show the posted at details when the record has not been posted from mobile client" do
				child = Child.new(:posted_at=> "2007-01-01 10:04pm", :unique_id=>"bob", :_id=>"123123", :created_by => 'jsmith', :created_at => "July 19 2010 13:05:32UTC")
      	  child.stub!(:has_one_interviewer?).and_return(true)
					form_section = FormSection.new :unique_id => "section_name", :enabled => "true"

          user = User.new()
        
        	assigns[:form_sections] = [form_section]
    	  	assigns[:child] = child
          assigns[:user] = user

       		render

        	response.should have_selector("#interviewer_details") do |fields|
          		fields[0].should_not contain("Posted from the mobile client at: 2007-01-01 10:04pm")
        	end 
			end
		end

  end

end
