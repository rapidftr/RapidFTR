require 'spec_helper'

describe AllChildrenComposer do

  def mock_child(name = "abc", created_at = Time.now)
    Child.new(:name => name, :created_at => created_at)
  end

  describe "#compose" do
    it "should sort children based on created_at when order is 'most recently created'" do
      child1, child2, child3 = [mock_child(2.days.ago), mock_child(1.day.ago),mock_child(Time.now)]
      children = [child1, child2, child3]
      composer = AllChildrenComposer.new('most recently created')
      composed_children = composer.compose(children)
      composed_children.should == [child3, child2, child1]
    end

    it "should sort children based on name when nil order is passed" do
      child1, child2, child3 = [mock_child("ghi"), mock_child("def"),mock_child("abc")]
      children = [child1, child2, child3]
      composer = AllChildrenComposer.new(nil)
      composed_children = composer.compose(children)
      composed_children.should == [child3, child2, child1]
    end

    it "should sort the children based on name when order is not 'most recently created'" do
      child1, child2, child3 = [mock_child("ghi"), mock_child("def"),mock_child("abc")]
      children = [child1, child2, child3]
      composer = AllChildrenComposer.new("some other order")
      composed_children = composer.compose(children)
      composed_children.should == [child3, child2, child1]
    end
  end
end
