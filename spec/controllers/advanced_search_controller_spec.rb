require 'spec_helper'

describe AdvancedSearchController do

  before do
    fake_login
  end

  def inject_export_generator( fake_export_generator, child_data )
    ExportGenerator.stub!(:new).with(child_data).and_return( fake_export_generator )
  end

  def stub_out_child_get(mock_child = mock(Child))
    Child.stub(:get).and_return( mock_child )
    mock_child
  end

  def stub_out_export_generator child_data = []
    inject_export_generator( stub_export_generator = stub(ExportGenerator) , child_data)
    stub_export_generator.stub!(:child_photos).and_return('')
    stub_export_generator
  end


  describe 'collection' do
    it "GET export_data" do
      controller.current_ability.should_receive(:can?).with(:export_pdf, Child).and_return(false);
      
      get :export_data, :commit => "Export Selected to PDF"
      
      response.should render_template("#{Rails.root}/public/403.html")
    end
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
      :criteria_list
    end

    it "should show list of enabled forms" do
      FormSection.stub(:by_order).and_return :some_forms
      get :index
      assigns[:forms].should == :some_forms
    end

    it "should perform a search using the parameters passed to it for admin users" do
      fake_admin_login
      search = mock("search_criteria")
      SearchCriteria.stub!(:build_from_params).and_return([search])
      fake_results = [:fake_child, :fake_child]
      fake_full_results = [:fake_child, :fake_child, :fake_child, :fake_child]
      SearchService.should_receive(:search).with(2, [search]).and_return([fake_results, fake_full_results])

      get :index, :page => 2, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil

      assigns[:results].should == fake_results
    end

    it "should append created_by as self for limited users" do
      search = mock("search_criteria")
      SearchCriteria.stub!(:build_from_params).and_return([search])
      fake_full_results = [:fake_child, :fake_child, :fake_child, :fake_child]
      stub_results = [:created_by, :created_by_value, :disable_create]
      created_by = mock("created_by")
      SearchFilter.should_receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return(created_by)
      SearchService.should_receive(:search).with(1, [search,created_by]).and_return([stub_results, fake_full_results])

      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil

      assigns[:results].should == stub_results
    end

    it "should construct criteria objects for advanced child search for admin" do
      fake_admin_login
      SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      assigns[:criteria_list].should == ["criteria_list"]
    end

    it "should construct criteria objects for advanced child search for limited access users" do
      SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
      created_by_mock = mock("Created_by")
      SearchFilter.should_receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return(created_by_mock)
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      assigns[:criteria_list].should include "criteria_list"
      assigns[:criteria_list].should include created_by_mock
    end

    context 'search filters' do

      it "should append search filter 'created_by' to the list of search criteria for admin" do
        fake_admin_login
        SearchCriteria.stub(:build_from_params).and_return([])
        SearchFilter.should_receive(:new).with({:field => "created_by", :field2 => "created_by_full_name", :value => "johnny_user", :join => 'AND', :index => 1}).and_return("created_by_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => "johnny_user"
        assigns[:criteria_list].should include("created_by_filter")
      end

      it "should append search filter 'updated_by' to the list of search criteria" do
        SearchCriteria.stub(:build_from_params).and_return([])
        SearchFilter.should_receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return("created_by")
        SearchFilter.should_receive(:new).with({:field => "last_updated_by", :field2 => "last_updated_by_full_name", :value => "johnny_user", :join => 'AND', :index => 2}).and_return("updated_by_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_by_value => "johnny_user"
        assigns[:criteria_list].should include("updated_by_filter")
      end

      it "should append search range 'created_at' to the list of search criteria" do
        SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
        SearchDateFilter.should_receive(:new).with({:field => "created_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z", :join => 'AND', :index => 1}).and_return("created_at_range")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_at_after_value => "2012-04-23", :created_at_before_value => "2012-04-25"
        assigns[:criteria_list].should include("created_at_range")
      end

      it "should append search range 'updated_at' to the list of search criteria" do
        SearchCriteria.stub(:build_from_params).and_return(["criteria_list"])
        SearchDateFilter.should_receive(:new).with({:field => "last_updated_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z", :join => 'AND', :index => 2}).and_return("updated_at_range")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_at_after_value => "2012-04-23", :updated_at_before_value => "2012-04-25"
        assigns[:criteria_list].should include("updated_at_range")
      end

      it "should append search filter 'created_by_organisation' to the list of search criteria for admin" do
        fake_admin_login
        SearchCriteria.stub(:build_from_params).and_return([])
        SearchFilter.should_receive(:new).with({:field => "created_organisation", :value => "STC", :join => 'AND', :index => 1}).and_return("created_by_organisation_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_organisation_value => "STC"
        assigns[:criteria_list].should include("created_by_organisation_filter")
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

  describe "export data" do
    before :each do
      @child1 = build :child
      @child2 = build :child
      controller.stub! :authorize! => true, :render => true
    end

    it "should handle full PDF" do
      Addons::PdfExportTask.any_instance.should_receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to PDF" }
    end

    it "should handle Photowall PDF" do
      Addons::PhotowallExportTask.any_instance.should_receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Photo Wall" }
    end

    it "should handle CSV" do
      Addons::CsvExportTask.any_instance.should_receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should handle custom export addon" do
      mock_addon = double()
      mock_addon_class = double(:new => mock_addon, :id => "mock")
      RapidftrAddon::ExportTask.stub! :active => [ mock_addon_class ]
      controller.stub(:t).with("addons.export_task.mock.selected").and_return("Export Selected to Mock")
      mock_addon.should_receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Mock" }
    end

    it "should encrypt result" do
      Addons::CsvExportTask.any_instance.should_receive(:export).with([ @child1, @child2 ]).and_return('data')
      controller.should_receive(:export_filename).with([ @child1, @child2 ], Addons::CsvExportTask).and_return("test_filename")
      controller.should_receive(:encrypt_exported_files).with('data', 'test_filename').and_return(true)
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should generate filename based on child ID and addon ID when there is only one child" do
      @child1.stub! :short_id => 'test_short_id'
      controller.send(:export_filename, [ @child1 ], Addons::PhotowallExportTask).should == "test_short_id_photowall.zip"
    end

    it "should generate filename based on username and addon ID when there are multiple children" do
      controller.stub! :current_user_name => 'test_user'
      controller.send(:export_filename, [ @child1, @child2 ], Addons::PdfExportTask).should == "test_user_pdf.zip"
    end
  end
end
