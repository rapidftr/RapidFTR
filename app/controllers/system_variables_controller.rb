class SystemVariablesController < ApplicationController
  def index
    authorize! :read, SystemUsers
    @system_variables = SystemVariable.all.all
  end

  def update
    authorize! :update, SystemUsers
    params[:system_variables].keys.each do |id|
      variable = SystemVariable.find(id)
      old_value = variable.value
      variable.value = params[:system_variables][id]
      variable.save!

      if variable.name == SystemVariable::SCORE_THRESHOLD && variable.value != old_value
        Enquiry.update_all_child_matches
      end
    end

    redirect_to system_variables_path
  end
end
