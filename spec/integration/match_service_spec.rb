require 'spec_helper'

describe MatchService, :type => :request, :solr => true do

  before :each do
    reset_couchdb!

    form = create :form, :name => Enquiry::FORM_NAME

    create :form_section, :name => 'test_form', :fields => [
      build(:text_field, :name => 'name', :matchable => true),
      build(:text_field, :name => 'nationality', :matchable => true),
      build(:text_field, :name => 'country', :matchable => true),
      build(:text_field, :name => 'birthplace', :matchable => true),
      build(:text_field, :name => 'languages', :matchable => true)
    ], :form => form
    Sunspot.remove_all(Child)

    allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
    allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
  end

  it 'should match children from a country given enquiry criteria with key different from childs country key ' do
    Sunspot.setup(Child) do
      text :location
      text :nationality
      text :country
    end
    child1 = Child.create!(:name => 'christine', :created_by => 'me', :country => 'uganda', :created_organisation => 'stc', :location => '', :nationality => '')
    child2 = Child.create!(:name => 'john', :created_by => 'not me', :nationality => 'uganda', :created_organisation => 'stc',  :location => '', :country => '')
    enquiry = Enquiry.create!(:name => 'Foo Bar', :gender => 'male', :nationality => 'uganda', :country => '', :location => '')

    hits = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(hits.size).to eq(2)
    expect(hits.keys).to include(*[child1.id, child2.id])
  end

  it 'should match records when criteria has a space' do
    Sunspot.setup(Child) do
      text :country
    end
    child = Child.create!(:name => 'Christine', :created_by => 'me', :country => 'Republic of Uganda', :created_organisation => 'stc')
    enquiry = Enquiry.create!(:enquirer_name => 'Foo Bar', :gender => 'male', :country => 'uganda')

    hits = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(hits.size).to eq(1)
    expect(hits.keys.first).to eq(child.id)
  end

  it 'should match multiple records given multiple criteria' do
    Sunspot.setup(Child) do
      text :location
      text :birthplace
      text :languages
    end
    Child.create!(:name => 'Christine', :created_by => 'me', :country => 'Republic of Uganda', :created_organisation => 'stc')
    Child.create!(:name => 'Man', :created_by => 'me', :nationality => 'Uganda', :gender => 'Male', :created_organisation => 'stc')
    Child.create!(:name => 'dude', :created_by => 'me', :birthplace => 'Dodoma', :languages => 'Swahili', :created_organisation => 'stc')
    enquiry = Enquiry.create!(:enquirer_name => 'Foo Bar', :gender => 'male', :country => 'uganda', :birthplace => 'dodoma', :languages => 'Swahili')

    children = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(children.size).to eq(3)
  end

  it 'should return empty array if criteria is empty' do
    expect(MatchService.search_for_matching_children({})).to eq([])
  end
end
