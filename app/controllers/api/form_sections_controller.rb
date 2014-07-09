class Api::FormSectionsController < Api::ApiController

  def index
    render json: FormSection.enabled_by_order_without_hidden_fields.map(&:formatted_hash)
  end

end
