require "spec_helper"

describe SearchCriteria, :type => :model do
  
  before(:each) do
    FormSection.all.each{ |form| form.destroy }

    form = FormSection.new(:name => "test_form")
    form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "display_name1")
    form.fields << Field.new(:name => "origin", :type => Field::TEXT_FIELD, :display_name => "display_name2")
    form.fields << Field.new(:name => "last_known_location", :type => Field::TEXT_FIELD, :display_name => "display_name3")
    form.save!
  end
  
  after(:each) do
    FormSection.all.each{ |form| form.destroy }
  end

  it "should construct advanced search parameters to criteria objects" do
    search_criteria = SearchCriteria.create_advanced_criteria({:field => "created_by", :value => "johnny01", :index => 123})
    expect(search_criteria.field).to eq("created_by")
    expect(search_criteria.value).to eq("johnny01")
    expect(search_criteria.join).to eq("AND")
    expect(search_criteria.index).to eq('123')
  end
  
  it "should construct criteria objects" do    
    criteria_list = SearchCriteria.build_from_params("1" => {:field => "name", :value => "kevin", :join => "AND", :display_name => "name" } )
    first_criteria = criteria_list.first
    expect(first_criteria.field).to eq("name")
    expect(first_criteria.value).to eq("kevin")
    expect(first_criteria.join).to eq("AND")
  end
  
  it "should remove whitespace from query" do    
     criteria_list = SearchCriteria.build_from_params("1" => {
       :field => "name", :value => "  \r\nkevin\t\n", :join => "", :display_name => "name" } )

     first_criteria = criteria_list.first
     expect(first_criteria.value).to eq("kevin")
   end
  
  it "should order by criteria index" do
    criteria_list = {
      "2" => {:field => "name", :value => "", :join => "" },
      "3" => {:field => "origin", :value => "", :join => "" },
      "1" => {:field => "last_known_location", :value => "", :join => "" } }
    result_criteria_list = SearchCriteria.build_from_params criteria_list
    
    expect(result_criteria_list.length).to eq(3)
    expect(result_criteria_list[0].field).to eq("last_known_location")
    expect(result_criteria_list[1].field).to eq("name")
    expect(result_criteria_list[2].field).to eq("origin")
  end
  
  it "should build query for one criteria with no join" do
    criteria_list = [double(:join => "", :to_lucene_query => "QUERY")]
    expect(SearchCriteria.lucene_query(criteria_list)).to eq("QUERY")
  end
  
  it "should build query for ANDed criteria" do
    criteria_list = [ 
      double(:join => "", :to_lucene_query => "QUERY1"), 
      double(:join => "AND", :to_lucene_query => "QUERY2")
    ]
    expect(SearchCriteria.lucene_query(criteria_list)).to eq("(QUERY1 AND QUERY2)")
  end
  
  it "should build query for ORed criteria" do
     criteria_list = [ 
       double(:join => "", :to_lucene_query => "QUERY1"), 
       double(:join => "OR", :to_lucene_query => "QUERY2")
     ]
     expect(SearchCriteria.lucene_query(criteria_list)).to eq("QUERY1 OR QUERY2")
  end

  it "should build query for downcase ORed criteria" do
    criteria_list = [
        double(:join => "", :to_lucene_query => "QUERY1"),
        double(:join => "or", :to_lucene_query => "QUERY2")
    ]
    expect(SearchCriteria.lucene_query(criteria_list)).to eq("QUERY1 OR QUERY2")
  end

  it "should build query for multiple OR criteria" do
     criteria_list = [ 
       double(:join => "", :to_lucene_query => "QUERY1"), 
       double(:join => "OR", :to_lucene_query => "QUERY2"),
       double(:join => "OR", :to_lucene_query => "QUERY3")
     ]
     expect(SearchCriteria.lucene_query(criteria_list)).to eq("QUERY1 OR QUERY2 OR QUERY3") 
  end
  
  it "should build query for criteria with AND having precedence" do
     criteria_list = [ 
       double(:join => "", :to_lucene_query => "QUERY1"), 
       double(:join => "AND", :to_lucene_query => "QUERY2"),
       double(:join => "OR", :to_lucene_query => "QUERY3")
     ]
     expect(SearchCriteria.lucene_query(criteria_list)).to eq("(QUERY1 AND QUERY2) OR QUERY3")
  end
  
  it "should build query for multiple AND criteria with first join having precedence" do
     criteria_list = [ 
       double(:join => "", :to_lucene_query => "QUERY1"), 
       double(:join => "AND", :to_lucene_query => "QUERY2"),
       double(:join => "AND", :to_lucene_query => "QUERY3")
     ]
     expect(SearchCriteria.lucene_query(criteria_list)).to eq("((QUERY1 AND QUERY2) AND QUERY3)")
  end
  
  it "should build query for mixed multiple AND and OR criteria with first AND join having precedence" do
     criteria_list = [ 
       double(:join => "", :to_lucene_query => "QUERY1"), 
       double(:join => "AND", :to_lucene_query => "QUERY2"),
       double(:join => "OR", :to_lucene_query => "QUERY3"),
       double(:join => "AND", :to_lucene_query => "QUERY4"),
       double(:join => "AND", :to_lucene_query => "QUERY5")
     ]
     expect(SearchCriteria.lucene_query(criteria_list)).to eq("(QUERY1 AND QUERY2) OR ((QUERY3 AND QUERY4) AND QUERY5)")
  end
  
  it "should build query for mixed multiple AND and multiple OR criteria with AND joins having precedence" do
      criteria_list = [ 
        double(:join => "", :to_lucene_query => "QUERY1"), 
        double(:join => "AND", :to_lucene_query => "QUERY2"),
        double(:join => "OR", :to_lucene_query => "QUERY3"),
        double(:join => "AND", :to_lucene_query => "QUERY4"),
        double(:join => "AND", :to_lucene_query => "QUERY5")
      ]
      expect(SearchCriteria.lucene_query(criteria_list)).to eq("(QUERY1 AND QUERY2) OR ((QUERY3 AND QUERY4) AND QUERY5)")
  end

  it "should build query for criteria without query" do
    criteria_list = [
      double(:join => "", :to_lucene_query => ""), 
      double(:join => "AND", :to_lucene_query => "CRITERIA")
    ]
    expect(SearchCriteria.lucene_query(criteria_list)).to eq("CRITERIA")
  end
end
