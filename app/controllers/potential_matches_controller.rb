class PotentialMatchesController < ApplicationController
  def destroy
    authorize! :update, Enquiry

    enquiry = Enquiry.find params[:enquiry_id]
    enquiry[:potential_matches].delete params[:id]
    enquiry.ids_marked_as_not_matching << params[:id]
    enquiry.save
    flash[:notice] = t('enquiry.messages.child_record_marked_as_not_a_match_successfully')
    redirect_to url_for :controller => :enquiries, :action => :show, :id => enquiry.id, :anchor => 'tab_potential_matches'
  end
end
