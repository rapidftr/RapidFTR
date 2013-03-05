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

    result = SearchService.search(1, [criteria])
    result.first.should == [child]
  end

  it "Should be able to search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "consultant")
    child2 = Child.create( :name => "rahul", :company => "travellor")
    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "consultant", :join => "AND")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should == [child1]
  end

  it "Should be able to search by fields criteria with space" do
    child1 = Child.create( :name => "tim", :company => "developer consultant")
    criteria1 = SearchCriteria.new(:field => "company", :value => "developer consultant")

    result = SearchService.search(1, [criteria1])
    result.first.should == [child1]
  end

  it "Should be able to search by fields ORed" do
    child1 = Child.create( :name => "tim", :company => "developer consultant")
    child2 = Child.create( :name => "rahul", :company => "travellor")
    child3 = Child.create( :name => "chris", :company => "marathonman")
    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "marathonman", :join => "OR")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should =~ [child1,child3]
  end

  it "Should be able to search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tom")
    criteria2 = SearchCriteria.new(:field => "company", :value => "firoman", :join => "AND")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should == []
  end

  it "Should be able to starts with search by fields ANDed" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "ti")
    criteria2 = SearchCriteria.new(:field => "company", :value => "fir", :join => "AND")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should == [child1]
  end

  it "Should be able to starts with search by fields Ored" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "tom", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tim")
    criteria2 = SearchCriteria.new(:field => "company", :value => "stu", :join => "OR")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should =~ [child1, child2]
  end

  it "Should be able to search by field values Ored" do
    child1 = Child.create( :name => "tim", :company => "fireman")
    child2 = Child.create( :name => "kevin", :company => "student")

    criteria1 = SearchCriteria.new(:field => "name", :value => "tim OR kevon")

    result = SearchService.search(1, [criteria1])
    result.first.should =~ [child1]
  end

  it "Should find children by created_by" do
    child1 = Child.create( :name => "tim", :company => "fireman", :created_by => "john")
    child2 = Child.create( :name => "tom", :company => "student", :created_by => "jill")
    child3 = Child.create( :name => "tox", :company => "student", :created_by => "jill")

    criteria1 = SearchCriteria.new(:field => "name", :value => "t")
    criteria2 = SearchCriteria.new(:field => "created_by", :value => "jill", :join => "AND")

    result = SearchService.search(1, [criteria1,criteria2])
    result.first.should == [child2, child3]
  end

  it "should call index instead of index! while creating the child in production env" do
    Sunspot.should_receive(:index).twice
    Rails.stub(:env).and_return(mock('env', :production? => true))
    Child.create(:name => "some name")
  end

end
