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
     get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => nil
     assigns[:results].should == fake_results
  end


  it "should construct empty criteria objects for new search" do
    SearchCriteria.stub(:new).and_return("empty_criteria")
    get :new
    response.should render_template('advanced_search/index.html.erb')
    assigns[:criteria_list].should == ["empty_criteria"]
  end
  
  it "should construct criteria objects for advanced child search " do
    SearchService.stub(:search).and_return([])
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    
    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => nil
    assigns[:criteria_list].should == ["criteria_list"]

  end

  it "should append advanced user criteria" do
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_criteria")
    SearchService.stub(:search).with(["criteria_list", "advanced_criteria"]).and_return([])

    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => "johnny_user"

    assigns[:criteria_list].should == ["criteria_list"]
    assigns[:user_details_criteria_list].should == ["advanced_criteria"]
  end

  it "should construct criteria list for only advanced user criteria" do
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_user_details")
    SearchCriteria.stub(:new).and_return("empty_criteria")
    SearchService.stub(:search).and_return([])

    get :index, :criteria_list => {"0"=>{"field"=>"", "value"=>"", "index"=>"0"}},
                :created_by_value => "johnny_user"

    assigns[:user_details_criteria_list].should == ["advanced_user_details"]
    assigns[:criteria_list].should == ["empty_criteria"]
  end
  
  it "should order by criteria index" do
    SearchService.stub(:search).and_return([])
    
    get :index
    assigns[:criteria_list].length.should == 1
    assigns[:criteria_list].first.field.should == ""
    assigns[:criteria_list].first.value.should == ""
  end

  it "should say child fields have been selected" do
    controller = AdvancedSearchController.new
    controller.child_fields_selected?({"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}).should == true
  end

  it "should say child fields have NOT been selected" do
    controller = AdvancedSearchController.new
    controller.child_fields_selected?({"0"=>{"field"=>"", "value"=>"", "index"=>"0"}}).should == false
  end
  
  it "should show list of enabled forms" do
    SearchService.stub(:search).and_return([])
    FormSection.stub(:by_order).and_return :some_forms
    
    get :index
    assigns[:forms].should == :some_forms
  end

end