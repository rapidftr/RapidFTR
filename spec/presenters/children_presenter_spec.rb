require 'spec_helper'

describe ChildrenPresenter do

  def stub_child(reunited = false, created_at = Time.now, name = "abc")
    child = Child.new({:created_at => created_at, :reunited => reunited, :name => name})
  end

  it "should use active composer as default composer when no filter is specified" do
    children = [stub_child(false), stub_child(false)]
    presenter = ChildrenPresenter.new children, nil, nil
    presenter.filter.should == "active"
    presenter.children.size.should == 2
  end
end
