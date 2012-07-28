require 'spec_helper'

describe ReunitedChildrenComposer do
  describe "#compose" do

    def mock_child(reunited = true, datetime = Time.now, name = "some name")
      child = Child.new(:reunited => reunited, :name => name)
      child['histories'] = [{'changes' => {'reunited' => 'does not matter'}, 'datetime' => datetime}]
      child
    end

    it "should select reunited children" do
      children = [mock_child(false), mock_child, mock_child]
      composer = ReunitedChildrenComposer.new("most recently reunited")
      composed_children = composer.compose(children)
      composed_children.should =~ [children[1], children[2]]
    end

    it "should apply reunited_at data on each reunited child" do
      children = [mock_child, mock_child]
      composer = ReunitedChildrenComposer.new("most recently reunited")
      composed_children = composer.compose(children)
      composed_children.map{|c| c.reunited_at }.should =~ [children[0]['reunited_at'], children[1]['reunited_at']]
    end

    it "should sort by reunited_at if the order passed in is 'most recently reunited'" do
      children = [mock_child(true, 3.day.ago), mock_child(true, 2.days.ago)]
      composer = ReunitedChildrenComposer.new("most recently reunited")
      composed_children = composer.compose(children)
      composed_children.should == [children[1], children[0]]
    end

    it "should sort by name if the order passed in is not 'most recently reunited'" do
      children = [mock_child(true, 3.day.ago, "def"), mock_child(true, 2.days.ago, "abc"), mock_child(true, 1.day.ago, "ghi")]
      composer = ReunitedChildrenComposer.new("some other order")
      composed_children = composer.compose(children)
      composed_children.should == [children[1], children[0], children[2]]
    end
  end
end
