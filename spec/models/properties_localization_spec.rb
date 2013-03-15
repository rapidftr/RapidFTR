require 'spec_helper'

class PropertiesLocalizationTestClass
  class << self
    alias_method :property, :cattr_accessor
  end

  include PropertiesLocalization
  PropertiesLocalization.localize_properties [ :property1, :property2 ]
end

describe PropertiesLocalization do

  before :each do
    @subject = PropertiesLocalizationTestClass.new
  end

  it "should return default translation missing message" do
    I18n.should_receive(:t).with("translation_missing", :default => "Translation Missing").and_return("test")
    I18n.default_locale = I18n.locale = :ar
    @subject.property1.should == "test"
  end

end