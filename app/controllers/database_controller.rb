class DatabaseController < ApplicationController

  def delete_children
    if Rails.env.android?
      Child.all.each do |child|
        child.destroy
      end
      render :text => "Deleted all child documents"
    else
      render :text => "Operation not allowed in #{Rails.env} environment"
    end

  end

end