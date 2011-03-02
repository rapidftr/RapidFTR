require 'spec_helper'

describe AdvancedSearchController do
  before do
    fake_login
  end
  
  it "should construct criteria objects" do
    SearchService.stub(:search).and_return([])
    SearchCriteria.stub(:build_from_params).and_return("criteria_list")
    
    get :index, :criteria_list => "something"
    assigns[:criteria_list].should == "criteria_list"
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
  
  
  
end