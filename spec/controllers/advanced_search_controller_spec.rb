require 'spec_helper'

describe AdvancedSearchController, :type => :controller do

  before do
    fake_login
  end

  def inject_export_generator( fake_export_generator, child_data )
    allow(ExportGenerator).to receive(:new).with(child_data).and_return( fake_export_generator )
  end

  def stub_out_child_get(mock_child = double(Child))
    allow(Child).to receive(:get).and_return( mock_child )
    mock_child
  end

  def stub_out_export_generator child_data = []
    inject_export_generator( stub_export_generator = double(ExportGenerator) , child_data)
    allow(stub_export_generator).to receive(:child_photos).and_return('')
    stub_export_generator
  end


  describe 'collection' do
    it "GET export_data" do
      expect(controller.current_ability).to receive(:can?).with(:export_pdf, Child).and_return(false);

      get :export_data, :commit => "Export Selected to PDF"

      expect(response.status).to eq(403)
    end
  end

  context 'new search' do

    it "should construct empty criteria objects for new search" do
      allow(SearchCriteria).to receive(:new).and_return("empty_criteria")
      get :new
      expect(response).to render_template('index')
      expect(assigns[:criteria_list]).to eq(["empty_criteria"])
    end

  end

  context 'search' do

    before do
      allow(SearchService).to receive(:search).and_return([])
      :criteria_list
    end

    it "should show list of enabled forms" do
      allow(FormSection).to receive(:by_order).and_return :some_forms
      get :index
      expect(assigns[:forms]).to eq(:some_forms)
    end

    it "should perform a search using the parameters passed to it for admin users" do
      fake_admin_login
      search = double("search_criteria")
      allow(SearchCriteria).to receive(:build_from_params).and_return([search])
      fake_results = [:fake_child, :fake_child]
      fake_full_results = [:fake_child, :fake_child, :fake_child, :fake_child]
      expect(SearchService).to receive(:search).with(2, [search]).and_return([fake_results, fake_full_results])

      get :index, :page => 2, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil

      expect(assigns[:results]).to eq(fake_results)
    end

    it "should append created_by as self for limited users" do
      search = double("search_criteria")
      allow(SearchCriteria).to receive(:build_from_params).and_return([search])
      fake_full_results = [:fake_child, :fake_child, :fake_child, :fake_child]
      stub_results = [:created_by, :created_by_value, :disable_create]
      created_by = double("created_by")
      expect(SearchFilter).to receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return(created_by)
      expect(SearchService).to receive(:search).with(1, [search,created_by]).and_return([stub_results, fake_full_results])

      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil

      expect(assigns[:results]).to eq(stub_results)
    end

    it "should construct criteria objects for advanced child search for admin" do
      fake_admin_login
      allow(SearchCriteria).to receive(:build_from_params).and_return(["criteria_list"])
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      expect(assigns[:criteria_list]).to eq(["criteria_list"])
    end

    it "should construct criteria objects for advanced child search for limited access users" do
      allow(SearchCriteria).to receive(:build_from_params).and_return(["criteria_list"])
      created_by_mock = double("Created_by")
      expect(SearchFilter).to receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return(created_by_mock)
      get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => nil
      expect(assigns[:criteria_list]).to include "criteria_list"
      expect(assigns[:criteria_list]).to include created_by_mock
    end

    context 'search filters' do

      it "should append search filter 'created_by' to the list of search criteria for admin" do
        fake_admin_login
        allow(SearchCriteria).to receive(:build_from_params).and_return([])
        expect(SearchFilter).to receive(:new).with({:field => "created_by", :field2 => "created_by_full_name", :value => "johnny_user", :join => 'AND', :index => 1}).and_return("created_by_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_value => "johnny_user"
        expect(assigns[:criteria_list]).to include("created_by_filter")
      end

      it "should append search filter 'updated_by' to the list of search criteria" do
        allow(SearchCriteria).to receive(:build_from_params).and_return([])
        expect(SearchFilter).to receive(:new).with({:value=>"fakeuser", :join=>"AND", :field=>"created_by", :index=>1, :field2=>"created_by_full_name"}).and_return("created_by")
        expect(SearchFilter).to receive(:new).with({:field => "last_updated_by", :field2 => "last_updated_by_full_name", :value => "johnny_user", :join => 'AND', :index => 2}).and_return("updated_by_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_by_value => "johnny_user"
        expect(assigns[:criteria_list]).to include("updated_by_filter")
      end

      it "should append search range 'created_at' to the list of search criteria" do
        allow(SearchCriteria).to receive(:build_from_params).and_return(["criteria_list"])
        expect(SearchDateFilter).to receive(:new).with({:field => "created_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z", :join => 'AND', :index => 1}).and_return("created_at_range")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_at_after_value => "2012-04-23", :created_at_before_value => "2012-04-25"
        expect(assigns[:criteria_list]).to include("created_at_range")
      end

      it "should append search range 'updated_at' to the list of search criteria" do
        allow(SearchCriteria).to receive(:build_from_params).and_return(["criteria_list"])
        expect(SearchDateFilter).to receive(:new).with({:field => "last_updated_at", :from_value => "2012-04-23T00:00:00Z", :to_value => "2012-04-25T00:00:00Z", :join => 'AND', :index => 2}).and_return("updated_at_range")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :updated_at_after_value => "2012-04-23", :updated_at_before_value => "2012-04-25"
        expect(assigns[:criteria_list]).to include("updated_at_range")
      end

      it "should append search filter 'created_by_organisation' to the list of search criteria for admin" do
        fake_admin_login
        allow(SearchCriteria).to receive(:build_from_params).and_return([])
        expect(SearchFilter).to receive(:new).with({:field => "created_organisation", :value => "STC", :join => 'AND', :index => 1}).and_return("created_by_organisation_filter")
        get :index, :criteria_list => {"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}}, :created_by_organisation_value => "STC"
        expect(assigns[:criteria_list]).to include("created_by_organisation_filter")
      end
    end

  end

  context 'constructor' do
    let(:controller) { AdvancedSearchController.new }

    it "should say child fields have been selected" do
      expect(controller.child_fields_selected?({"0" => {"field" => "name_of_child", "value" => "joe joe", "index" => "0"}})).to eq(true)
    end

    it "should say child fields have NOT been selected" do
      expect(controller.child_fields_selected?({"0" => {"field" => "", "value" => "", "index" => "0"}})).to eq(false)
    end
  end

  describe "export data" do
    before :each do
      @child1 = build :child
      @child2 = build :child
      controller.stub :authorize! => true, :render => true
    end

    it "should handle full PDF" do
      expect_any_instance_of(Addons::PdfExportTask).to receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to PDF" }
    end

    it "should handle Photowall PDF" do
      expect_any_instance_of(Addons::PhotowallExportTask).to receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Photo Wall" }
    end

    it "should handle CSV" do
      expect_any_instance_of(Addons::CsvExportTask).to receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should handle custom export addon" do
      mock_addon = double()
      mock_addon_class = double(:new => mock_addon, :id => "mock")
      RapidftrAddon::ExportTask.stub :active => [ mock_addon_class ]
      allow(controller).to receive(:t).with("addons.export_task.mock.selected").and_return("Export Selected to Mock")
      expect(mock_addon).to receive(:export).with([ @child1, @child2 ]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Mock" }
    end

    it "should encrypt result" do
      expect_any_instance_of(Addons::CsvExportTask).to receive(:export).with([ @child1, @child2 ]).and_return('data')
      expect(controller).to receive(:export_filename).with([ @child1, @child2 ], Addons::CsvExportTask).and_return("test_filename")
      expect(controller).to receive(:encrypt_exported_files).with('data', 'test_filename').and_return(true)
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should generate filename based on child ID and addon ID when there is only one child" do
      @child1.stub :short_id => 'test_short_id'
      expect(controller.send(:export_filename, [ @child1 ], Addons::PhotowallExportTask)).to eq("test_short_id_photowall.zip")
    end

    it "should generate filename based on username and addon ID when there are multiple children" do
      controller.stub :current_user_name => 'test_user'
      expect(controller.send(:export_filename, [ @child1, @child2 ], Addons::PdfExportTask)).to eq("test_user_pdf.zip")
    end
  end
end
