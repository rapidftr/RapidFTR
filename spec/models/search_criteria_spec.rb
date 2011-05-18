require "spec_helper"

describe SearchCriteria do
  
  before(:all) do 
    form = FormSection.new(:name => "test_form")
    form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "display_name1")
    form.fields << Field.new(:name => "origin", :type => Field::TEXT_FIELD, :display_name => "display_name2")
    form.fields << Field.new(:name => "last_known_location", :type => Field::TEXT_FIELD, :display_name => "display_name3")
    form.save!
  end 
  
  after(:all) do
    FormSection.all.each{ |form| form.destroy }
  end

  it "should construct advanced search parameters to criteria objects" do
    search_criteria = SearchCriteria.create_advanced_criteria({:field => "created_by", :value => "johnny01", :index => 123})
    search_criteria.field.should == "created_by"
    search_criteria.value.should == "johnny01"
    search_criteria.join.should == "AND"
    search_criteria.index.should == '123'
  end
  
  it "should construct criteria objects" do    
    criteria_list = SearchCriteria.build_from_params("1" => {:field => "name", :value => "kevin", :join => "AND", :display_name => "name" } )
    first_criteria = criteria_list.first
    first_criteria.field.should == "name"
    first_criteria.value.should == "kevin"
    first_criteria.join.should == "AND"
  end
  
  it "should remove whitespace from query" do    
     criteria_list = SearchCriteria.build_from_params("1" => {
       :field => "name", :value => "  \r\nkevin\t\n", :join => "", :display_name => "name" } )

     first_criteria = criteria_list.first
     first_criteria.value.should == "kevin"
   end
  
  it "should order by criteria index" do
    criteria_list = {
      "2" => {:field => "name", :value => "", :join => "" },
      "3" => {:field => "origin", :value => "", :join => "" },
      "1" => {:field => "last_known_location", :value => "", :join => "" } }
    result_criteria_list = SearchCriteria.build_from_params criteria_list
    
    result_criteria_list.length.should == 3
    result_criteria_list[0].field.should == "last_known_location"
    result_criteria_list[1].field.should == "name"
    result_criteria_list[2].field.should == "origin"
  end
  
  it "should build query for one criteria with no join" do
    criteria_list = [mock(:join => "", :to_lucene_query => "QUERY")]
    SearchCriteria.lucene_query(criteria_list).should == "QUERY"
  end
  
  it "should build query for ANDed criteria" do
    criteria_list = [ 
      mock(:join => "", :to_lucene_query => "QUERY1"), 
      mock(:join => "AND", :to_lucene_query => "QUERY2")
    ]
    SearchCriteria.lucene_query(criteria_list).should == "(QUERY1 AND QUERY2)"
  end
  
  it "should build query for ORed criteria" do
     criteria_list = [ 
       mock(:join => "", :to_lucene_query => "QUERY1"), 
       mock(:join => "OR", :to_lucene_query => "QUERY2")
     ]
     SearchCriteria.lucene_query(criteria_list).should == "QUERY1 OR QUERY2"
  end
  
  it "should build query for multiple OR criteria" do
     criteria_list = [ 
       mock(:join => "", :to_lucene_query => "QUERY1"), 
       mock(:join => "OR", :to_lucene_query => "QUERY2"),
       mock(:join => "OR", :to_lucene_query => "QUERY3")
     ]
     SearchCriteria.lucene_query(criteria_list).should == "QUERY1 OR QUERY2 OR QUERY3" 
  end
  
  it "should build query for criteria with AND having precedence" do
     criteria_list = [ 
       mock(:join => "", :to_lucene_query => "QUERY1"), 
       mock(:join => "AND", :to_lucene_query => "QUERY2"),
       mock(:join => "OR", :to_lucene_query => "QUERY3")
     ]
     SearchCriteria.lucene_query(criteria_list).should == "(QUERY1 AND QUERY2) OR QUERY3"
  end
  
  it "should build query for multiple AND criteria with first join having precedence" do
     criteria_list = [ 
       mock(:join => "", :to_lucene_query => "QUERY1"), 
       mock(:join => "AND", :to_lucene_query => "QUERY2"),
       mock(:join => "AND", :to_lucene_query => "QUERY3")
     ]
     SearchCriteria.lucene_query(criteria_list).should == "((QUERY1 AND QUERY2) AND QUERY3)"
  end
  
  it "should build query for mixed multiple AND and OR criteria with first AND join having precedence" do
     criteria_list = [ 
       mock(:join => "", :to_lucene_query => "QUERY1"), 
       mock(:join => "AND", :to_lucene_query => "QUERY2"),
       mock(:join => "OR", :to_lucene_query => "QUERY3"),
       mock(:join => "AND", :to_lucene_query => "QUERY4"),
       mock(:join => "AND", :to_lucene_query => "QUERY5")
     ]
     SearchCriteria.lucene_query(criteria_list).should == "(QUERY1 AND QUERY2) OR ((QUERY3 AND QUERY4) AND QUERY5)"
  end
  
  it "should build query for mixed multiple AND and multiple OR criteria with AND joins having precedence" do
      criteria_list = [ 
        mock(:join => "", :to_lucene_query => "QUERY1"), 
        mock(:join => "AND", :to_lucene_query => "QUERY2"),
        mock(:join => "OR", :to_lucene_query => "QUERY3"),
        mock(:join => "AND", :to_lucene_query => "QUERY4"),
        mock(:join => "AND", :to_lucene_query => "QUERY5")
      ]
      SearchCriteria.lucene_query(criteria_list).should == "(QUERY1 AND QUERY2) OR ((QUERY3 AND QUERY4) AND QUERY5)"
  end

  
end