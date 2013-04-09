class Api::ChildrenController < ApplicationController
	before_filter :current_user

	def index
		respond_to do |format|
			format.json do 
				authorize! :index, Child
				render :json => Child.all
			end
		end
	end

end