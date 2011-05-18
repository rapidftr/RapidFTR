require 'spec_helper'

describe HighlightFieldsController do

  describe "index" do
    it "should have no highlight fields" do
      FormSection.stub(:highlighted_fields).and_return([])
      fake_admin_login 
      get :index
      assigns[:highlighted_fields].should be_empty          
    end
    
    it "should have forms assigned" do
      FormSection.stub(:all).and_return([FormSection.new(:name => "Form1"), FormSection.new(:name => "Form2")])
      fake_admin_login
      get :index
      assigns[:forms].size.should == 2
    end

    it "should have highlighted fields assigned" do
      field1 = Field.new(:name => "field1", :display_name => "field1_display" , :highlight_information => { :order => "1", :highlighted => true })
      field2 = Field.new(:name => "field2", :display_name => "field2_display" , :highlight_information => { :order => "2", :highlighted => true })
      field3 = Field.new(:name => "field3", :display_name => "field3_display" , :highlight_information => { :order => "3", :highlighted => true })
      FormSection.new(:name => "Form1", :fields => [field1])
      FormSection.new(:name => "Form2", :fields => [field2])
      FormSection.new(:name => "Form3", :fields => [field3])
      FormSection.stub(:highlighted_fields).and_return([field1, field2, field3])
      fake_admin_login
      get :index
      assigns[:highlighted_fields] == [ {:field_name => "field1", :display_name => "field1_display" , :order => "1", :form_name => "Form1" },
                                        {:field_name => "field1", :display_name => "field1_display" , :order => "1", :form_name => "Form1" },
                                        {:field_name => "field1", :display_name => "field1_display" , :order => "1", :form_name => "Form1" } ]
    end
  end
end
