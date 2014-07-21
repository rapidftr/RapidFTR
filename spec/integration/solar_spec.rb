require 'rubygems'
require 'sunspot' # In the real world we should probably vendor this.
require 'spec_helper'

describe "Solar", type: :request, solr: true do

  def fuzzy_search(input)
    Sunspot.search(Child) do
      fulltext input, fields: [:name]
    end
  end

  before :all do
    Sunspot.remove_all(Child)

    create :form_section, fields: [
      build(:text_field, name: 'name')
    ]

    @child1 = create(:child, 'last_known_location' => "New York", "name" => "Mohammed Smith")
    @child2 = create(:child, 'last_known_location' => "New York", "name" => "Muhammed Jones")
    @child3 = create(:child, 'last_known_location' => "New York", "name" => "Muhammad Brown")
    @child4 = create(:child, 'last_known_location' => "New York", "name" => "Ammad Brown")
  end

  it "should match on the first part of a child's first name" do
    search = fuzzy_search("Muha")
    expect(search.results.map(&:name).sort).to eq(["Mohammed Smith", "Muhammad Brown", "Muhammed Jones"])
  end

  it "should match on the first part of a child's last name" do
    search = fuzzy_search("Bro")
    expect(search.results.map(&:name).sort).to eq(["Ammad Brown", "Muhammad Brown"])
  end

  it "should match on approximate spelling of a child's entire first name" do
    search = fuzzy_search("Mohamed")
    expect(search.results.map(&:name).sort).to eq(["Mohammed Smith", "Muhammad Brown", "Muhammed Jones"])
  end

  it "should support partial reindexing" do
    search = fuzzy_search("Mohamed")
    expect(search.results.map(&:name).sort).to eq(["Mohammed Smith", "Muhammad Brown", "Muhammed Jones"])
  end

end

describe "Enquiry Mapping", type: :request, solr: true do

  before :all do
    Sunspot.remove_all(Child)

    create :form_section, fields: [
      build(:text_field, name: 'name')
    ]

    @child1 = create(:child, 'last_known_location' => "New York", "name" => "Mohammed Smith")
    @child2 = create(:child, 'last_known_location' => "New York", "name" => "Muhammed Jones")
    @child3 = create(:child, 'last_known_location' => "New York", "name" => "Muhammad Brown")
    @child4 = create(:child, 'last_known_location' => "New York", "name" => "Ammad Brown")
    @enquiry = Enquiry.create("enquirer_name" => "Kavitha", "criteria" => {"name" => "Ammad"}, "reporter_details" => {"location" => "Kyangwali"})
  end

  def match(criteria)
    child_criteria = ""
    criteria.values.each do |value|
      child_criteria.concat value
    end
    child_criteria.downcase!
    Sunspot.search(Child) do
      fulltext("#{child_criteria}* OR #{child_criteria}~")
      adjust_solr_params do |params|
        params[:defType] = "dismax"
      end
    end
  end

  it "should match enquiry with child record" do
    matches = match(@enquiry["criteria"])
    expect(matches.results.map(&:name).sort).to eq(["Ammad Brown"])
    expect(matches.results.map(&:name).sort).not_to include("Muhammad Brown")
  end

end
