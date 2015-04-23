module Api
  class EnquiriesController < ApiController
    before_action :sanitise_params

    def create
      authorize! :create, Enquiry

      unless Enquiry.get(enquiry_json['id']).nil?
        render_error('errors.models.enquiry.create_forbidden', 403) && return
      end

      @enquiry = update_enquiry_from params

      unless @enquiry.valid?
        render(:json => {:error => @enquiry.errors.full_messages}, :status => 422) && return
      end

      Enquiry.without_histories { @enquiry.save }
      render :json => @enquiry.without_internal_fields, :status => 201
    end

    def update
      authorize! :update, Enquiry

      enquiry = Enquiry.get(params[:id])
      if enquiry.nil?
        render_error('errors.models.enquiry.not_found', 404)
        return
      end
      enquiry = update_enquiry_from(params)
      unless enquiry.valid?
        render :json => {:error => enquiry.errors.full_messages}, :status => 422
        return
      end

      Enquiry.without_histories { enquiry.save! }
      render :json => enquiry.without_internal_fields
    end

    def index
      authorize! :index, Enquiry
      if params[:updated_after].nil?
        enquiries = Enquiry.all
      else
        updated_after = Time.parse(URI.decode(params[:updated_after]))
        enquiries = Enquiry.all.select do |enquiry|
          enquiry.updated_at > updated_after
        end
      end

      urls = enquiries.sort { |champion, challenger| Time.parse(champion.updated_at) <=> Time.parse(challenger.updated_at) }.map do |enquiry|
        {:location => "#{request.scheme}://#{request.host}:#{request.port}#{request.path}/#{enquiry[:_id]}"}
      end
      render(:json => urls)
    end

    def show
      authorize! :show, Enquiry
      enquiry = Enquiry.get(params[:id])
      if !enquiry.nil?
        render :json => enquiry.without_internal_fields
      else
        render :json => '', :status => 404
      end
    end

    private

    def update_enquiry_from(params)
      enquiry = enquiry || Enquiry.get(params[:id]) || Enquiry.new_with_user_name(current_user, params[:enquiry])
      enquiry.update_with_attachments(params, current_user, :enquiry)
      enquiry
    end

    def render_error(message, status_code)
      render :json => {:error => I18n.t(message)}, :status => status_code
    end

    def sanitise_params
      unless (params[:updated_after]).nil?
        DateTime.parse params[:updated_after]
      end

      # histories might come from the mobile client as a string
      params['enquiry']['histories'] = JSON.parse(params['enquiry']['histories']) if params['enquiry'] && params['enquiry']['histories'].is_a?(String)
    rescue
      render :json => 'Invalid request', :status => 422
    end

    def enquiry_json
      if params['enquiry'].is_a?(String)
        enquiry = JSON.parse(params['enquiry'])
      else
        enquiry = params['enquiry']
      end
      enquiry
    end
  end
end
