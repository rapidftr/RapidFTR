require "spec_helper"

describe MatchService, type: :request, solr: true do

  before :each do
    reset_couchdb!

    form = create :form, name: Enquiry::FORM_NAME

    create :form_section, name: 'test_form', fields: [
      build(:text_field, name: 'name'),
      build(:text_field, name: 'nationality'),
      build(:text_field, name: 'country'),
      build(:text_field, name: 'birthplace'),
      build(:text_field, name: 'languages')
    ], form: form
  end

  before :each do
    Sunspot.remove_all(Child)
  end

  it "should match children from a country given enquiry criteria with key different from child's country key " do
    Sunspot.setup(Child) do
      text :location
      text :nationality
      text :country
    end
    child1 = Child.create!(:name => "christine", :created_by => "me", :country => "uganda", :created_organisation => "stc")
    child2 = Child.create!(:name => "john", :created_by => "not me", :nationality => "uganda", :created_organisation => "stc")
    enquiry = Enquiry.create!(:name => "Foo Bar", :gender => "male", :nationality => "uganda")

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(2)
    expect(children).to include(*[child1, child2])
  end

  it "should match records when criteria has a space" do
    Sunspot.setup(Child) do
      text :country
    end
    Child.create!(:name => "Christine", :created_by => "me", :country => "Republic of Uganda", :created_organisation => "stc")
    enquiry = Enquiry.create!(:enquirer_name => "Foo Bar", :gender => "male", :country => "uganda")

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(1)
    expect(children.first.name).to eq("Christine")
  end

  it "should match multiple records given multiple criteria" do
    Sunspot.setup(Child) do
      text :location
      text :birthplace
      text :languages
    end
    Child.create!(:name => "Christine", :created_by => "me", :country => "Republic of Uganda", :created_organisation => "stc")
    Child.create!(:name => "Man", :created_by => "me", :nationality => "Uganda", :gender => "Male", :created_organisation => "stc")
    Child.create!(:name => "dude", :created_by => "me", :birthplace => "Dodoma", :languages => "Swahili", :created_organisation => "stc")
    enquiry = Enquiry.create!(:enquirer_name => "Foo Bar", :gender => "male", :country => "uganda", :birthplace => "dodoma", :languages => "Swahili")

    children = MatchService.search_for_matching_children(enquiry["criteria"])

    expect(children.size).to eq(3)
  end

end
