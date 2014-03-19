require 'spec_helper'

describe PropertiesLocalization do

  before :each do
    RapidFTR::Application.stub :locales => [ "a", "b" ]
    @klass = Class.new(CouchRest::Model::Base) do
      include PropertiesLocalization
    end
    @klass.localize_properties [ :name ]
    @object = @klass.new
  end

  it "should create localized properties" do
    @object.should be_respond_to "name_a"
    @object.should be_respond_to "name_b"
  end

  it "should create default property which sets system default locale" do
    I18n.stub :default_locale => :b
    @object.name = "test"
    @object.name_b.should == "test"
    @object.name_a.should == nil
  end

  it "should create all property which sets all locales" do
    @object.name_all = "test"
    @object.name_a.should == "test"
    @object.name_b.should == "test"
  end

  it "should use constructor for default property" do
    I18n.stub :default_locale => :b
    @object = @klass.new "name" => "test"
    @object.name_b.should == "test"
    @object.name_a.should == nil
  end

  it "should use constructor for all properties" do
    @object = @klass.new "name_all" => "test"
    @object.name_a.should == "test"
    @object.name_b.should == "test"
  end

  it "should provide formatted hash of locale data" do
    @object = @klass.new name_a: "test a", name_b: "test b"
    @object.formatted_hash.should == { "name_a" => "test a", "name_b" => "test b" }
  end

  it "should normalize line encoding in formatted hash" do
    @object = @klass.new name_a: "test a\r\ntest a", name_b: "test b\r\ntest b"
    @object.formatted_hash.should == { "name_a" => "test a\ntest a", "name_b" => "test b\ntest b" }
  end

end
