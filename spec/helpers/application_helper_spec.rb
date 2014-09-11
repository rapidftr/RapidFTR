require 'spec_helper'

describe ApplicationHelper, :type => :helper do
  describe '#current_url_with_format_of' do
    it 'should preserve controller, action, and other params' do
      controller.params['action'] = 'search'
      controller.params['controller'] = 'search'
      controller.params['param_a'] = 'foo'

      expect(helper.current_url_with_format_of('csv')).to eq(
        '/search.csv?param_a=foo'
      )
    end

    it 'should override any existing format' do
      controller.params['action'] = 'search'
      controller.params['controller'] = 'search'
      controller.params[:format] = 'pdf'

      url = helper.current_url_with_format_of('csv')
      expect(url).to include('.csv')
      expect(url).not_to include('.pdf')
    end
  end
end
