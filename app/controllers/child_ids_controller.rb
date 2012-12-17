class ChildIdsController < ApplicationController
  def all
    children = Child.all
    render :json => children.collect { |c| { "_id" => c.id, "_rev" => c.rev } }
  end
end
