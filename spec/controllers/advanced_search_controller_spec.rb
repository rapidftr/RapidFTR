require 'spec_helper'

describe AdvancedSearchController do
  before do
    fake_login
  end

  it "performs a search using non-advanced parameters passed to it" do
     search = mock("search_criteria")
     SearchCriteria.stub!(:build_from_params).and_return([search])

     fake_results = [:fake_child,:fake_child]
     SearchService.should_receive(:search).with([search]).and_return(fake_results)
     get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => nil

     assigns[:results].should == fake_results
  end

  it "performs a search using advanced parameters passed to it" do
     search = mock("search_criteria")
     advanced_search = mock("advanced_search_criteria")

     SearchCriteria.stub!(:build_from_params).and_return([search])
     SearchCriteria.stub!(:create_advanced_criteria).and_return(advanced_search)

     fake_results = [:fake_child,:fake_child]
     SearchService.should_receive(:search).with([search]+[advanced_search]).and_return(fake_results)
     get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => 'john'
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

  it "should create advanced user criteria for created by" do
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_criteria")
    SearchService.stub(:search).and_return([])

    SearchCriteria.should_receive(:create_advanced_criteria).with({:field => "created_by", :value => "johnny_user", :index => 12})
    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :created_by_value => "johnny_user"

    assigns[:criteria_list].should == ["criteria_list"]
    assigns[:advanced_criteria_list].should == ["advanced_criteria"]
  end

  it "should create advanced user criteria for updated by" do
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_criteria")
    SearchService.stub(:search).and_return([])

    SearchCriteria.should_receive(:create_advanced_criteria).with({:field => "last_updated_by", :value => "johnny_user", :index => 13})

    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, :updated_by_value => "johnny_user"

    assigns[:criteria_list].should == ["criteria_list"]
    assigns[:advanced_criteria_list].should == ["advanced_criteria"]
  end

  it "should filter search results by date created" do
    SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_criteria")
    SearchService.stub(:search).and_return("child_records")

    created_at_start = "30-01-2011"
    created_at_end  = "20-02-2011"

    SearchService.should_receive(:search)
    SearchService.should_receive(:filter_by_date).with("child_records", created_at_start, created_at_end)
    get :index, :criteria_list => {"0"=>{"field"=>"name_of_child", "value"=>"joe joe", "index"=>"0"}}, 
      :created_at_start_value => created_at_start, :created_at_end_value => created_at_end

    assigns[:criteria_list].should == ["criteria_list"]
    assigns[:advanced_criteria_list].should == []
  end


  it "should construct criteria list for only advanced user criteria" do
    SearchCriteria.stub(:create_advanced_criteria).and_return("advanced_user_details")
    SearchService.stub(:search).and_return([])

    get :index, :criteria_list => {"0"=>{"field"=>"", "value"=>"", "index"=>"0"}},
                :created_by_value => "johnny_user"

    assigns[:criteria_list].should == []
    assigns[:advanced_criteria_list].should == ["advanced_user_details"]
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
