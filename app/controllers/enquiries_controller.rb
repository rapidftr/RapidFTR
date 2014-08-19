class EnquiriesController < ApplicationController
  def new
    @enquiry = Enquiry.new
    @form_sections = enquiry_form_sections
  end

  def create
    authorize! :create, Enquiry
    @enquiry = Enquiry.new_with_user_name current_user, params[:enquiry]

    if @enquiry.save
      flash['notice'] = t('enquiry.messages.creation_success')
      redirect_to(@enquiry)
    else
      @form_sections = enquiry_form_sections
      render :action => 'new'
    end
  end

  def show
    authorize! :read, Enquiry
    @enquiry = Enquiry.find params[:id]
    @form_sections = enquiry_form_sections
  end

  private

  def enquiry_form_sections
    FormSection.enabled_by_order_for_form(Enquiry::FORM_NAME)
  end
end
