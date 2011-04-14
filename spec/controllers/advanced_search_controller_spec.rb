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
  end
  
  it "should order by criteria index" do
    SearchService.stub(:search).and_return([])
    
    get :index
    assigns[:criteria_list].length.should == 1
    assigns[:criteria_list].first.field.should == ""
    assigns[:criteria_list].first.value.should == ""
  end
  
  it "should show list of enabled forms" do
    SearchService.stub(:search).and_return([])
    FormSection.stub(:by_order).and_return :some_forms
    
    get :index
    assigns[:forms].should == :some_forms
  end
  
  
end