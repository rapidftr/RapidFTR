require 'spec_helper'

describe ActiveChildrenComposer do
  
  def mock_child(reunited = false, created_at = Time.now, name = "abc")
    child = Child.new({:created_at => created_at, :reunited => reunited, :name => name})
  end

  describe "#compose" do
    it "should select children who are not reunited" do
      children = [mock_child, mock_child, mock_child(true)]
      composer = ActiveChildrenComposer.new("most recently created")
      children_composed = composer.compose(children)
      children_composed.map{|c| c.reunited? }.should == [false, false]
    end

    it "should sort children based on created_at if order passed is 'most recently created'" do
      children = [mock_child(false, 2.day.ago), mock_child(false, 1.days.ago), mock_child(true)]
      composer = ActiveChildrenComposer.new("most recently created")
      children_composed = composer.compose(children)
      children_composed.should == [children[1], children[0]]
    end

    it "should sort children based on name if order passed is not 'most recently created'" do
      children = [mock_child(false, 2.day.ago, "def"), mock_child(false, 1.days.ago, "abc"), mock_child(true, 1.day.ago, "does not matter")]
      composer = ActiveChildrenComposer.new("some other order")
      children_composed = composer.compose(children)
      children_composed.should == [children[1], children[0]]
    end
  end
end
