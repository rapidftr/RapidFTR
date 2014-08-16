require 'spec_helper'

describe UsersHelper, :type => :helper do

  # Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    expect(included_modules).to include(UsersHelper)
  end

end
