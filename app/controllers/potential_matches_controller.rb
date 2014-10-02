class PotentialMatchesController < ApplicationController
  before_action :authorize_update
  before_action :load_potential_match
  before_action :parse_return_to_value

  def destroy
    @potential_match.mark_as_invalid
    @potential_match.save
    flash[:notice] = t('enquiry.messages.child_record_marked_as_not_a_match_successfully')
    redirect_to url_for :controller => @model_controller, :action => :show, :id => @model_id, :anchor => 'tab_potential_matches'
  end

  def update
    unless params[:confirmed].nil?
      confirmed = params[:confirmed] == 'true' || params[:confirmed] == true
      if confirmed
        @potential_match.mark_as_confirmed
      else
        @potential_match.mark_as_potential_match
      end

      @potential_match.save!
    end
    redirect_to url_for :controller => @model_controller, :action => :show, :id => @model_id, :anchor => 'tab_potential_matches'
  end

  private

  def load_potential_match
    enquiry_id = params.delete(:enquiry_id)
    child_id = params.delete(:id)
    @potential_match = PotentialMatch.by_enquiry_id_and_child_id.key([enquiry_id, child_id]).all.first
  end

  def parse_return_to_value
    return_to_child = params[:return] == 'child'
    @model_controller =  return_to_child ? :children : :enquiries
    @model_id = return_to_child ? @potential_match.child_id : @potential_match.enquiry_id
  end

  def authorize_update
    authorize! :update, Enquiry
  end
end
