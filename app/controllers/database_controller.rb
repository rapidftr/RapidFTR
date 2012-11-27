class DatabaseController < ApplicationController

  def delete_children
    if Rails.env.android?
      Child.all.each do |child|
        child.destroy
      end
    end
    render :text => "Reseeded the database"
  end

end