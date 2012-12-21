require 'spec_helper'

describe FlaggedChildrenComposer do

  def flag_child(flag, name = "test")
    child = Child.new
    child['name'] = name
    child['flag'] = flag
    child
  end

  def add_history(child, datetime = Time.now)
    child['histories'] = [{'changes' => {'flag' => ""}, "datetime" => datetime}]
    child
  end

  describe "#compose" do
    context "when passed in order of 'most recently flagged'" do
      before do
        @composer = FlaggedChildrenComposer.new("most recently flagged")
      end

      it "should set the flagged_at attribute for each flagged child" do
        now = Time.now
        yesterday = Time.new.yesterday
        children = [add_history(flag_child('true'), now), add_history(flag_child('true'), yesterday)]
        flagged_children = @composer.compose(children)
        flagged_children.map{|c| c['flagged_at']}.should =~ [now, yesterday]
      end

      it "should sort the children by flagged_at" do
        now = Time.now
        yesterday = Time.new.yesterday
        children = [add_history(flag_child('true'), yesterday), add_history(flag_child('true'), now)]
        flagged_children = @composer.compose(children)
        flagged_children.map{|c| c['flagged_at']}.should == [now, yesterday]
      end
    end

    context "when passed in an order other than 'most recently flagged'" do
      before do
        @composer = FlaggedChildrenComposer.new("whatever")
      end

      it "should sort the children by name" do
        children = [flag_child('true', "def"), flag_child('true', "abc")]
        flagged_children = @composer.compose(children)
        flagged_children.map{|c| c['name']}.should == ["abc", "def"]
      end
    end
  end
end
