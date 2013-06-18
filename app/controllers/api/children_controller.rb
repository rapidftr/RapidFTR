class Api::ChildrenController < Api::ApiController

  before_filter :sanitize_params, :only => [:update, :create, :unverified]

  def index
		authorize! :index, Child
		render :json => Child.all
	end

	def show
    authorize! :show, Child
    child = Child.get params[:id]

    if child
      render :json => child.compact
    else
      render :json => nil, :status => 404
    end
	end

  def create
	 	authorize! :create, Child
		create_or_update_child(params)
		@child['created_by_full_name'] = current_user_full_name

  	@child.save!
    render :json => @child.compact
	end

  def update
		authorize! :update, Child
    
    child = update_child_from params

    child.save!
    render :json => child.compact
  end

  def unverified
    params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
    unless params[:child][:_id]
      params[:child].merge!(:verified => current_user.verified?)
      child = create_or_update_child(params)

      child['created_by_full_name'] = current_user.full_name
      if child.save
        render :json => child.compact
      end
    else
      child = Child.get(params[:child][:_id])
      child = update_child_with_attachments child, params
      child.save
      render :json => child.compact
    end
  end

  def ids
    render :json => Child.fetch_all_ids_and_revs
  end

  private

  def sanitize_params
    params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    child_params = params['child']
    child_params['histories'] = JSON.parse(child_params['histories']) if child_params and child_params['histories'].is_a?(String) #histories might come as string from the mobile client.
  end

  def create_or_update_child(params)
    @child = Child.by_short_id(:key => child_short_id(params)).first if params[:child][:unique_identifier]
    if @child.nil?
      @child = Child.new_with_user_name(current_user, params[:child])
    else
      @child = update_child_from(params)
    end
  end

  def child_short_id params
    params[:child][:short_id] || params[:child][:unique_identifier].last(7)
  end

  def update_child_from params
    child = @child || Child.get(params[:id]) || Child.new_with_user_name(current_user, params[:child])
    child.update_with_attachments(params, current_user)
    child
  end
end
