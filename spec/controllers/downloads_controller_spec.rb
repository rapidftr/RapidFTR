require 'spec_helper'
#
#def inject_export_generator( fake_export_generator, child_data )
#  ExportGenerator.stub!(:new).with(child_data).and_return( fake_export_generator )
#end
#
#def stub_out_export_generator child_data = []
#  inject_export_generator( stub_export_generator = stub(ExportGenerator) , child_data)
#  stub_export_generator.stub!(:child_photos).and_return('')
#  stub_export_generator
#end
#


describe DownloadsController do

  before :each do
    fake_admin_login
  end

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs).as_null_object
  end

  describe '#authorizations' do
    describe 'collection' do
      it "POST children_data" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :children_data
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "POST child_data" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :child_data
        response.should render_template("#{Rails.root}/public/403.html")
      end
    end
  end

  describe "POST children_data" do
    describe "when the signed in user has access all data" do
      before do
        fake_admin_login
        @stubs ||= {}
      end

      it "should assign all childrens as @childrens" do
        children = [mock_child(@stubs)]
        @status = "all"

        Child.should_receive(:view).with(:by_all_view, :startkey => [@status], :endkey => [@status , {}]).and_return(children)

        post :children_data, { :password => "password" }
        assigns[:children].should == children
      end
    end
  end

  describe "POST child_data" do
      describe "when the signed in user has access to export data" do
        before do
          fake_admin_login
          @stubs ||= {}
        end

      end
    end

end