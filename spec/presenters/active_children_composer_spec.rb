require 'spec_helper'

describe ActiveChildrenComposer do

  def mock_child(reunited = false, created_at = Time.now, name = "abc")
    child = Child.new({:created_at => created_at, :reunited => reunited, :name => name})
  end

  describe "#compose" do
    it "should sort children based on created_at if order passed is 'most recently created'" do
      children = [mock_child(false, 2.days.ago), mock_child(false, 1.days.ago)]
      composer = ActiveChildrenComposer.new("most recently created")
      children_composed = composer.compose(children)
      children_composed.should == [children[0], children[1]]
    end

    it "should sort children based on name if order passed is not 'most recently created'" do
      children = [mock_child(false, 2.days.ago, "def"), mock_child(false, 1.days.ago, "abc")]
      composer = ActiveChildrenComposer.new("some other order")
      children_composed = composer.compose(children)
      children_composed.should == [children[0], children[1]]
    end

    it "should not break if the name is not present for the child" do
      children = [mock_child(false, 1.days.ago, ''), mock_child(false, 1.days.ago, 'a')]
      composer = ActiveChildrenComposer.new('name')
      composer.compose(children).should == [children[0], children[1]]
    end
  end
end
