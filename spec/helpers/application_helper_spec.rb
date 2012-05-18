require 'spec_helper'

describe ApplicationHelper do
  describe '#current_url_with_format_of' do
    it 'should preserve controller, action, and other params' do
      params['action'] = 'search'
      params['controller'] = 'children'
      params['param_a'] = 'foo'

      helper.current_url_with_format_of('csv').should ==
        '/children/search.csv?param_a=foo'
    end

    it 'should override any existing format' do
      params['action'] = 'search'
      params['controller'] = 'children'
      params[:format] = 'pdf'

      url = helper.current_url_with_format_of('csv')
      url.should include('.csv')
      url.should_not include('.pdf')
    end
  end
end
