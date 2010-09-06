
class ChildIdsController < ApplicationController

  def all
    children = Child.all
    render :json => children.collect { |c| { "id" => c.id, "rev" => c.rev } }
  end
    
end