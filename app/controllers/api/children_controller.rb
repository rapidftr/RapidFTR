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

	def show
		respond_to do |format|
			format.json do 
				authorize! :show, Child
				render :json => Child.get(params[:id]).compact
			end
		end
	end

  def create
    respond_to do |format|
    	format.json do
   	 		authorize! :create, Child
    		params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    		create_or_update_child(params[:child])
    		@child['created_by_full_name'] = current_user_full_name
    
      	if @child.save
        	render :json => @child.compact.to_json
      	end
    	end
  	end
	end

  def update
    respond_to do |format|
    	format.json do
    		authorize! :update, Child
        params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
        child = update_child_from params[:child]
        child.save
        render :json => child.compact.to_json
    	end
    end
  end

  def sync_unverified
    params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
    unless params[:child][:_id]
      respond_to do |format|
        format.json do

          child = create_or_update_child(params[:child].merge(:verified => current_user.verified?))

          child['created_by_full_name'] = current_user.full_name
          if child.save
            render :json => child.compact.to_json
          end
        end
      end
    else
      child = Child.get(params[:child][:_id])
      child = update_child_with_attachments child, params
      child.save
      render :json => child.compact.to_json
    end
  end

  private

    def create_or_update_child(child_params)
      @child = Child.by_short_id(:key => child_short_id(child_params)).first if child_params[:unique_identifier]
      if @child.nil?
        @child = Child.new_with_user_name(current_user, child_params)
      else
        @child = update_child_from(child_params)
      end
    end

    def child_short_id child_params
      child_params[:short_id] || child_params[:unique_identifier].last(7)
    end

    def update_child_from child_params
      child = @child || Child.get(params[:id]) || Child.new_with_user_name(current_user, child_params)
      child.update_with_attachments(child_params, current_user_full_name)
      child
    end

end