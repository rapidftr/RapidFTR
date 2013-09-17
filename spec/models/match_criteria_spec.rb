require "spec_helper"

describe MatchCriteria do

  it "should build dismax query for a single field" do
    criteria = {"nationality" => "uganda" }
    MatchCriteria.dismax_query(criteria).should == "(uganda~ OR uganda*)"
  end

  it "should build dismax query for fields with spaces" do
    criteria = {"name" => "Kevin Smith"}
    MatchCriteria.dismax_query(criteria).should == "(kevin~ OR kevin*) OR (smith~ OR smith*)"
  end

  it "should build dismax query for multiple fields" do
    criteria = {"nationality" => "uganda", "gender" => "male" }
    MatchCriteria.dismax_query(criteria).should == "(uganda~ OR uganda*) OR (male~ OR male*)"
  end

  it "should build dismax query for multiple fields including spaces" do
    criteria = {"nationality" => "uganda", "name" => "Kevin Smith", "gender" => "male" }
    MatchCriteria.dismax_query(criteria).should == "(uganda~ OR uganda*) OR (kevin~ OR kevin*) OR (smith~ OR smith*) OR (male~ OR male*)"
  end

end