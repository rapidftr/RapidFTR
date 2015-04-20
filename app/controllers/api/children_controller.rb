module Api
  class ChildrenController < ApiController
    before_action :check_device_blacklisted, :only => :show
    before_action :sanitize_params, :only => [:update, :create, :unverified]

    def index
      authorize! :index, Child

      if params[:updated_after].nil?
        children = Child.all
      else
        updated_after = Time.parse(URI.decode(params[:updated_after]))
        children = Child.all.select do |child|
          child_updated_at = Time.parse(child.last_updated_at)
          child_updated_at > updated_after
        end
      end
      render(:json => children.map { |child| {:location => "#{request.scheme}://#{request.host}:#{request.port}#{request.path}/#{child[:_id]}"} })
    end

    def show
      authorize! :show, Child
      child = Child.get params[:id]

      if child
        render :json => child.without_internal_fields
      else
        render :json => '', :status => 404
      end
    end

    def create
      authorize! :create, Child
      create_or_update_child(params)
      @child['created_by_full_name'] = current_user_full_name

      Child.without_histories { @child.save! }
      render :json => @child.without_internal_fields
    end

    def update
      authorize! :update, Child

      child = update_child_from params

      Child.without_histories { child.save! }
      render :json => child.without_internal_fields
    end

    def unverified
      params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
      if params[:child][:_id]
        child = Child.get(params[:child][:_id])
        child = child.update_with_attachments(params, current_user)
        child.save
        render :json => child.without_internal_fields
      else
        params[:child].merge!(:verified => current_user.verified?)
        child = create_or_update_child(params)

        child.attributes = {:created_by_full_name => current_user.full_name}
        if child.save
          render :json => child.without_internal_fields
        end
      end
    end

    def ids
      render :json => Child.fetch_all_ids_and_revs
    end

    private

    def sanitize_params
      super :child

      unless (params[:updated_after]).nil?
        DateTime.parse params[:updated_after]
      end

      params['child']['histories'] = JSON.parse(params['child']['histories']) if params['child'] && params['child']['histories'].is_a?(String) # histories might come as string from the mobile client.
    rescue JSON::ParserError
      render :json => {:error => I18n.t('errors.models.enquiry.malformed_query')}, :status => 422
    end

    def create_or_update_child(params)
      @child = Child.by_short_id(:key => child_short_id(params)).first if params[:child][:unique_identifier]
      @child = update_child_from(params)
    end

    def child_short_id(params)
      params[:child][:short_id] || params[:child][:unique_identifier].last(7)
    end

    def update_child_from(params)
      child = @child || Child.get(params[:id]) || Child.new_with_user_name(current_user, params[:child])
      child.update_with_attachments(params, current_user)
      child
    end
  end
end
