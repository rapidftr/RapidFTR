require 'spec_helper'

describe MatchService, :type => :request, :solr => true do

  before :each do
    reset_couchdb!

    form = create :form, :name => Child::FORM_NAME

    create :form_section, :name => 'test_form', :fields => [
      build(:text_field, :name => 'name_1', :matchable => true),
      build(:text_field, :name => 'nationality_1', :matchable => true),
      build(:text_field, :name => 'country_1', :matchable => true),
      build(:text_field, :name => 'birthplace_1', :matchable => true),
      build(:text_field, :name => 'languages_1', :matchable => true),
      build(:text_field, :name => 'other_1', :matchable => true)
    ], :form => form

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
      text :location_1
      text :nationality_1
      text :country_1
    end
    child1 = Child.create!(:name_1 => 'christine', :created_by => 'me', :country_1 => 'uganda', :created_organisation => 'stc', :location_1 => '', :nationality_1 => '')
    child2 = Child.create!(:name_1 => 'john', :created_by => 'not me', :nationality_1 => 'uganda', :created_organisation => 'stc',  :location_1 => '', :country_1 => '')
    enquiry = Enquiry.create!(:name => 'Foo Bar', :gender => 'male', :nationality => 'uganda', :country => '', :location => '')

    hits = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(hits.size).to eq(2)
    expect(hits.keys).to include(*[child1.id, child2.id])
  end

  it 'should match records when criteria has a space' do
    Sunspot.setup(Child) do
      text :country_1
    end
    child = Child.create!(:name_1 => 'Christine', :created_by => 'me', :country_1 => 'Republic of Uganda', :created_organisation => 'stc')
    enquiry = Enquiry.create!(:enquirer_name => 'Foo Bar', :gender => 'male', :country => 'uganda')

    hits = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(hits.size).to eq(1)
    expect(hits.keys.first).to eq(child.id)
  end

  it 'should match multiple records given multiple criteria' do
    Sunspot.setup(Child) do
      text :location_1
      text :birthplace_1
      text :languages_1
    end
    Child.create!(:name_1 => 'Christine', :created_by => 'me', :country_1 => 'Republic of Uganda', :created_organisation => 'stc')
    Child.create!(:name_1 => 'Man', :created_by => 'me', :nationality_1 => 'Uganda', :gender_1 => 'Male', :created_organisation => 'stc')
    Child.create!(:name_1 => 'dude', :created_by => 'me', :birthplace_1 => 'Dodoma', :languages_1 => 'Swahili', :created_organisation => 'stc')
    enquiry = Enquiry.create!(:enquirer_name => 'Foo Bar', :gender => 'male', :country => 'uganda', :birthplace => 'dodoma', :languages => 'Swahili')

    children = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(children.size).to eq(3)
  end

  it 'should not use unmatchable fields to search' do
    Sunspot.setup(Child) do
      text :name_1
      text :other_1
    end
    Child.create!(:name_1 => 'Man', :other_1 => 'Other', :created_by => 'me', :created_organisation => 'stc')
    expected_child = Child.create!(:name_1 => 'dude', :other_1 => 'Other', :created_by => 'me', :created_organisation => 'stc')
    enquiry = Enquiry.create!(:enquirer_name => 'Foo Bar', :name => 'dude', :other_1 => 'Other')

    children = MatchService.search_for_matching_children(enquiry['criteria'])

    expect(children.size).to eq(1)
    expect(children.first[0]).to eq(expected_child.id)
  end

  it 'should return empty array if criteria is empty' do
    expect(MatchService.search_for_matching_children({})).to eq([])
  end
end
