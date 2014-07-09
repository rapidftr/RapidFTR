require "spec_helper"

describe MatchService, :type => :request do

  before :all do
    FormSection.all.each(&:destroy)
    form = FormSection.new(:name => "test_form")
    form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "name")
    form.fields << Field.new(:name => "nationality", :type => Field::TEXT_FIELD, :display_name => "nationality")
    form.fields << Field.new(:name => "country", :type => Field::TEXT_FIELD, :display_name => "country")
    form.fields << Field.new(:name => "birthplace", :type => Field::TEXT_FIELD, :display_name => "birthplace")
    form.fields << Field.new(:name => "languages", :type => Field::TEXT_FIELD, :display_name => "languages")
    form.save!
  end

  after :all do
    FormSection.all.each{|form| form.destroy}
  end

  before :each do
    Sunspot.remove_all(Child)
  end

  it "should match children from a country given enquiry criteria with key different from child's country key " do
    Child.create!(:name => "christine", :created_by => "me", :country => "uganda", :created_organisation => "stc")
    Child.create!(:name => "john", :created_by => "not me", :nationality => "uganda", :created_organisation => "stc")
    enquiry = Enquiry.create!(:enquirer_name => "Foo Bar", :reporter_details => {:gender => "male"}, :criteria => {:location => "uganda"})

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(2)
    expect(children.first.name).to eq("christine")
    expect(children.last.name).to eq("john")
  end

  it "should match records when criteria has a space" do
    Child.create!(:name => "Christine", :created_by => "me", :country => "Republic of Uganda", :created_organisation => "stc")
    enquiry = Enquiry.create!(:enquirer_name => "Foo Bar", :reporter_details => {:gender => "male"}, :criteria => {:location => "uganda"})

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(1)
    expect(children.first.name).to eq("Christine")
  end

  it "should match multiple records given multiple criteria" do
    Child.create!(:name => "Christine", :created_by => "me", :country => "Republic of Uganda", :created_organisation => "stc")
    Child.create!(:name => "Man", :created_by => "me", :nationality => "Uganda", :gender => "Male", :created_organisation => "stc")
    Child.create!(:name => "dude", :created_by => "me", :birthplace => "Dodoma", :languages => "Swahili", :created_organisation => "stc")
    enquiry = Enquiry.create!(:enquirer_name => "Foo Bar", :reporter_details => {:gender => "male"}, :criteria => {:location => "uganda", :birthplace=>"dodoma", :languages => "Swahili"})

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(3)
  end

end
