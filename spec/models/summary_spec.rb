require 'spec'

describe Summary do

  describe "basic_search" do
    it "should return results in alphabetical order" do
      @result_from_db = [summary_with_name("zubair"), summary_with_name("alice")]
      Summary.stub(:view).with(any_args()).any_number_of_times().and_return(@result_from_db)
      results = Summary.basic_search("alice", "")
      results.first()["name"].should =="alice"
      results.last()["name"].should == "zubair"
    end
  end
  def summary_with_name(name)
    sum = Summary.new
    sum["name"] = name
    sum
  end

  describe "and arrays" do
    it "should and arrays ignoring empty ones" do
      empty = []
      first = [1,2,3]
      second = [2,3]
      result = Summary.and_arrays(empty, first, second).should == [2,3]
    end
  end
end