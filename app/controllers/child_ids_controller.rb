class ChildIdsController < ApplicationController
  def all
    child_json = Child.fetch_all_ids_and_revs
    render :json => child_json
  end
end
