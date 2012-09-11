require 'spec_helper'

describe AdvancedSearchController do

  before do
    fake_login
  end

  context 'new search' do

    it "should construct empty criteria objects for new search" do
      SearchCriteria.stub(:new).and_return("empty_criteria")
      get :new
      response.should render_template('index')
      assigns[:criteria_list].should == ["empty_criteria"]
    end

  end

  context 'search' do

    before do
      SearchService.stub(:search).and_return([])
    end

    it "should show list of enabled forms" do
      FormSection.stub(:by_order).and_return :some_forms
      get :index
      assigns[:forms].should == :some_forms
    end

    it "should perform a search using the parameters passed to it" do
      search = mock("search_criteria")
      SearchCriteria.stub!(:build_from_params).and_return([search])
      fake_results = [:fake_child, :fake_child]
      SearchService.should_receive(:search).with([search]).and_return(fake_results)
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      assigns[:results].should == fake_results
    end

    it "should construct criteria objects for advanced child search " do
      SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      assigns[:criteria_list].should == ["criteria_list"]
    end

    it "should order by criteria index" do
      get :index
      assigns[:criteria_list].length.should == 1
      assigns[:criteria_list].first.field.should == ""
      assigns[:criteria_list].first.value.should == ""
    end

    context 'search filters' do

        it "should append search filter 'created_by' to the list of search criteria" do
          SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
          SearchFilter.should_receive(:new).with({:field => "created_by", :field2 => "created_by_full_name", :value => "johnny_user", :join => 'AND', :index => 1}).and_return("created_by_filter")
          get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => "johnny_user"
          assigns[:criteria_list].should include("created_by_filter")
        end

        it "should append search filter 'updated_by' to the list of search criteria" do
          SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
          SearchFilter.should_receive(:new).with({:field => "last_updated_by", :field2 => "last_updated_by_full_name", :value => "johnny_user",  :join => 'AND', :index => 2}).and_return("updated_by_filter")
          get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_by_value => "johnny_user"
          assigns[:criteria_list].should include("updated_by_filter")
        end

        it "should append search range 'created_at' to the list of search criteria" do
          SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
          SearchDateFilter.should_receive(:new).with({:field => "created_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z",  :join => 'AND', :index => 1}).and_return("created_at_range")
          get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_at_after_value => "2012-04-23", :created_at_before_value => "2012-04-25"
          assigns[:criteria_list].should include("created_at_range")
        end

        it "should append search range 'updated_at' to the list of search criteria" do
          SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
          SearchDateFilter.should_receive(:new).with({:field => "last_updated_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z",  :join => 'AND', :index => 2}).and_return("updated_at_range")
          get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_at_after_value => "2012-04-23", :updated_at_before_value => "2012-04-25"
          assigns[:criteria_list].should include("updated_at_range")
        end

    end

  end

  context 'constructor' do

    let(:controller) { AdvancedSearchController.new }

    it "should say child fields have been selected" do
      controller.child_fields_selected?({"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}).should == true
    end

    it "should say child fields have NOT been selected" do
      controller.child_fields_selected?({"0" => {"field" => "", "value" => "", "index" => "0"}}).should == false
    end

  end

end