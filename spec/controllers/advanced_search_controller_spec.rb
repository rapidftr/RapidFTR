require 'spec_helper'

describe AdvancedSearchController, :type => :controller do

  before do
    fake_login
  end

  def inject_export_generator(fake_export_generator, child_data)
    allow(ExportGenerator).to receive(:new).with(child_data).and_return(fake_export_generator)
  end

  def stub_out_child_get(mock_child = double(Child))
    allow(Child).to receive(:get).and_return(mock_child)
    mock_child
  end

  def stub_out_export_generator(child_data = [])
    inject_export_generator(stub_export_generator = double(ExportGenerator), child_data)
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

  context 'search' do
    it "should construct empty criteria objects for new search" do
      get :index
      expect(response).to render_template('index')
    end

    it "should show list of enabled children forms" do
      form1 = build :form
      form2 = build :form
      form_section1 = build :form_section, form: form1
      form_section2 = build :form_section, form: form2
      form_sections = [form_section1, form_section2]
      allow(Form).to receive(:find_by_name).and_return form1
      allow(FormSection).to receive(:by_order).and_return form_sections
      get :index
      expect(assigns[:form_sections]).to eq([form_section1])
    end

    it "should create SearchForm with whatever params received" do
      search_form = Forms::SearchForm.new
      params = { a: 'a', b: 'b', c: 'c' }

      expect(Forms::SearchForm).to receive(:new).with(ability: controller.current_ability, params: hash_including(params)).and_return(search_form)
      expect(search_form).to receive(:execute)

      get :index, params
    end
  end

  describe "export data" do
    before :each do
      @child1 = create :child, created_by: controller.current_user_name
      @child2 = create :child, created_by: controller.current_user_name
      controller.stub :authorize! => true, :render => true
    end

    it "should handle full PDF" do
      expect_any_instance_of(Addons::PdfExportTask).to receive(:export).with([@child1, @child2]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to PDF" }
    end

    it "should handle Photowall PDF" do
      expect_any_instance_of(Addons::PhotowallExportTask).to receive(:export).with([@child1, @child2]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Photo Wall" }
    end

    it "should handle CSV" do
      expect_any_instance_of(Addons::CsvExportTask).to receive(:export).with([@child1, @child2]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should handle custom export addon" do
      mock_addon = double()
      mock_addon_class = double(:new => mock_addon, :id => "mock")
      RapidftrAddon::ExportTask.stub :active => [mock_addon_class]
      allow(controller).to receive(:t).with("addons.export_task.mock.selected").and_return("Export Selected to Mock")
      expect(mock_addon).to receive(:export).with([@child1, @child2]).and_return('data')
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to Mock" }
    end

    it "should encrypt result" do
      expect_any_instance_of(Addons::CsvExportTask).to receive(:export).with([@child1, @child2]).and_return('data')
      expect(controller).to receive(:export_filename).with([@child1, @child2], Addons::CsvExportTask).and_return("test_filename")
      expect(controller).to receive(:encrypt_exported_files).with('data', 'test_filename').and_return(true)
      post :export_data, { :selections => { '0' => @child1.id, '1' => @child2.id }, :commit => "Export Selected to CSV" }
    end

    it "should generate filename based on child ID and addon ID when there is only one child" do
      @child1.stub :short_id => 'test_short_id'
      expect(controller.send(:export_filename, [@child1], Addons::PhotowallExportTask)).to eq("test_short_id_photowall.zip")
    end

    it "should generate filename based on username and addon ID when there are multiple children" do
      controller.stub :current_user_name => 'test_user'
      expect(controller.send(:export_filename, [@child1, @child2], Addons::PdfExportTask)).to eq("test_user_pdf.zip")
    end
  end
end
