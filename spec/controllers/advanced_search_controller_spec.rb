require 'spec_helper'

describe AdvancedSearchController do
  before do
    fake_login
  end

  it "performs a search using the parameters passed to it" do
     search = mock("search_criteria")
     SearchCriteria.stub!(:build_from_params).and_return([search])

     fake_results = [:fake_child,:fake_child]
     SearchService.should_receive(:search).with([search]).and_return(fake_results)
     get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => ""
     assigns[:results].should == fake_results
  end


  it "should construct empty criteria objects for new search" do
    SearchCriteria.stub(:new).and_return("empty_criteria")
    get :index
    assigns[:criteria_list].should == ["empty_criteria"]
  end
  
  it "should construct criteria objects for advanced child search " do
    SearchService.stub(:search).and_return([])
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])

    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => ""
    assigns[:criteria_list].should == ["criteria_list"]
    # first_criteria = assigns[:criteria_list].first
    
    
    # get :index,  :criteria_list => {"1" => {:field => "name", :value => "kevin", :join => "AND", :display_name => "Name" } }
    # 
    # assigns[:criteria_list].length.should == 1
    # first_criteria = assigns[:criteria_list].first
    # first_criteria.field.should == "name"
    # first_criteria.value.should == "kevin"
    # first_criteria.join.should == "AND"
    # first_criteria.index.should == "1"
    
  end

  it "should append advanced user criteria" do
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_criteria")
    SearchService.stub(:search).and_return([])

    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => "johnny_user"

    assigns[:criteria_list].should == ["criteria_list", "advanced_criteria"]
  end

  it "should construct criteria list for only advanced user criteria" do
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_user_details")
    SearchService.stub(:search).and_return([])

    get :index, :criteria_list => {"0"=>{"field"=>"", "value"=>"", "index"=>"0"}},
                :created_by_value => "johnny_user"

    assigns[:criteria_list].should == ["advanced_user_details"]
  end
  
  it "should order by criteria index" do
    SearchService.stub(:search).and_return([])
    
    get :index
    assigns[:criteria_list].length.should == 1
    assigns[:criteria_list].first.field.should == ""
    assigns[:criteria_list].first.value.should == ""
    
    # SearchService.stub(:search).and_return([])
    # SearchService.stub(:build_from_params).and_return("criteria_list")
    # 
    # assigns[:criteria_list].should == "criteria_list"
    # 
    # SearchService.stub(:search).and_return([])
    # 
    # get :index,  :criteria_list => {
    #   "2" => {:field => "name", :value => "", :join => "" },
    #   "3" => {:field => "origin", :value => "", :join => "" },
    #   "1" => {:field => "last_known_location", :value => "", :join => "" } }
    # 
    # assigns[:criteria_list].length.should == 3
    # assigns[:criteria_list][0].field.should == "last_known_location"
    # assigns[:criteria_list][1].field.should == "name"
    # assigns[:criteria_list][2].field.should == "origin"
  end

  it "should say child fields have been selected" do
    controller = AdvancedSearchController.new
    controller.child_fields_selected?({"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}).should == true
  end

  it "should say child fields have NOT been selected" do
    controller = AdvancedSearchController.new
    controller.child_fields_selected?({"0"=>{"field"=>"", "value"=>"", "index"=>"0"}}).should == false
  end
end