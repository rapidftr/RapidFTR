require 'spec_helper'

describe ApplicationHelper do
  describe '#current_url_with_format_of' do
    it 'should preserve controller, action, and other params' do
      controller.params['action'] = 'search'
      controller.params['controller'] = 'children'
      controller.params['param_a'] = 'foo'

      helper.current_url_with_format_of('csv').should ==
        '/children/search.csv?param_a=foo'
    end

    it 'should override any existing format' do
      controller.params['action'] = 'search'
      controller.params['controller'] = 'children'
      controller.params[:format] = 'pdf'

      url = helper.current_url_with_format_of('csv')
      url.should include('.csv')
      url.should_not include('.pdf')
    end
  end

  describe "can_export?" do
    it "should return true if user has any of the export permissions" do
      user = mock('user', :user_name => 'name', :has_permission? => true)
      controller.stub(:current_user).and_return(user)

      user.stub!(:has_permission?).with(:export_csv, Child).and_return(true)
      user.stub!(:has_permission?).with(:export_pdf, Child).and_return(false)
      user.stub!(:has_permission?).with(:export_photowall, Child).and_return(false)

      helper.can_export?.should be_true
    end

    it "should return false if user has any of the export permissions" do
      user = mock('user', :user_name => 'name', :has_permission? => false)
      controller.stub(:current_user).and_return(user)

      helper.can_export?.should be_false
    end
  end

end
