require "spec_helper"

describe "SearchService" do
  
  before :each do 
    Sunspot.remove_all(Child)
  end
  
  before :all do  
    form = FormSection.new(:name => "test_form")
    form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "name")
    form.fields << Field.new(:name => "company", :type => Field::TEXT_FIELD, :display_name => "company")
    form.save!
  end
  
  after :all do
    FormSection.all.each{ |form| form.destroy }
  end
  
  it "Should be able to search by single field" do
    child = Child.create( :name => "tim", :company => "consultant")
    criteria = SearchCriteria.new(:field => "name", :value => "tim")

    result = SearchService.search [criteria]
    result.should == [child]
  end
  
  it "Should be able to search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "consultant")
    child2 = Child.create( :name => "rahul", :company => "travellor")
    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "consultant", :join => "AND")

    result = SearchService.search [criteria1,criteria2]
    result.should == [child1]
  end
  
  it "Should be able to search by fields criteria with space" do
    child1 = Child.create( :name => "tim", :company => "developer consultant")
    criteria1 = SearchCriteria.new(:field => "company", :value => "developer consultant")

    result = SearchService.search [criteria1]
    result.should == [child1]
  end
  
  it "Should be able to search by fields ORed" do
    child1 = Child.create( :name => "tim", :company => "developer consultant")
    child2 = Child.create( :name => "rahul", :company => "travellor")
    child3 = Child.create( :name => "chris", :company => "marathonman")
    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "marathonman", :join => "OR")

    result = SearchService.search [criteria1,criteria2]
    result.should =~ [child1,child3]
  end
     
  it "Should be able to fuzzy search by fields ORed" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")
    child3 = Child.create( :name => "kevin", :company => "headmaster")
    child4 = Child.create( :name => "chris", :company => "george")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "heodmaster", :join => "OR")

    result = SearchService.search [criteria1,criteria2]
    result.should =~ [child1, child2, child3]
  end

  it "Should be able to fuzzy search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tom")
    criteria2 = SearchCriteria.new(:field => "company", :value => "firoman", :join => "AND")

    result = SearchService.search [criteria1,criteria2]
    result.should == [child1]
  end
  
  it "Should be able to starts with search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "ti")
    criteria2 = SearchCriteria.new(:field => "company", :value => "fir", :join => "AND")

    result = SearchService.search [criteria1,criteria2]
    result.should == [child1]
  end
  
  it "Should be able to starts with search by fields Ored" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "stu", :join => "OR")

    result = SearchService.search [criteria1,criteria2]
    result.should =~ [child1, child2]
  end
  
  it "Should be able to starts with search by fields Ored" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "kevin", :company => "student")
  
    criteria1 = SearchCriteria.new(:field => "name", :value => "tim OR kevon")
    
    result = SearchService.search [criteria1]
    result.should =~ [child1, child2]
  end

  it "Should be able to filter search results by creation date (AFTER)" do
    child1 = Child.create!(:name => "jorge", :created_at => '01-01-2010')
    child2 = Child.create!(:name => "john",  :created_at => '01-02-2010')

    created_at_start = '15-01-2010'

    criteria = SearchCriteria.new(:field => "name", :value => "j")

    #get only child records created after 'created_at_start'
    result = SearchService.search [criteria]
    result = SearchService.filter_by_date(result, created_at_start, '')
    result.should == [child2]
  end
 
  it "Should be able to filter search results by creation date (BEFORE)" do
    child1 = Child.create!(:name => "jorge", :created_at => '01-01-2010')
    child2 = Child.create!(:name => "john",  :created_at => '01-02-2010')

    created_at_end = '15-01-2010'

    criteria = SearchCriteria.new(:field => "name", :value => "j")

    #get only child records created before 'created_at_end'
    result = SearchService.search [criteria]
    result = SearchService.filter_by_date(result, '', created_at_end)
    result.should == [child1]
  end

  it "Should be able to filter search results by creation date (BETWEEN)" do
    child1 = Child.create!(:name => "jorge", :created_at => '01-01-2010')
    child2 = Child.create!(:name => "john",  :created_at => '01-02-2010')
    child3 = Child.create!(:name => "josh",  :created_at => '01-03-2010')

    created_at_start, created_at_end = '15-01-2010', '15-02-2010'

    criteria = SearchCriteria.new(:field => "name", :value => "j")

    #get only child records created between 'created_at_start' and 'created_at_end'
    result = SearchService.search [criteria]
    result = SearchService.filter_by_date(result, created_at_start, created_at_end)
    result.should == [child2]
  end

end
