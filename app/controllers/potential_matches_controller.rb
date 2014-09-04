class PotentialMatchesController < ApplicationController
  def destroy
    authorize! :update, Enquiry
    enquiry_id = params[:enquiry_id]
    child_id = params[:id]
    PotentialMatch.by_enquiry_id_and_child_id.key([enquiry_id, child_id]).all.each do |pm|
      pm.mark_as_invalid
      pm.save
    end
    flash[:notice] = t('enquiry.messages.child_record_marked_as_not_a_match_successfully')
    redirect_to url_for :controller => :enquiries, :action => :show, :id => enquiry_id, :anchor => 'tab_potential_matches'
  end
end
