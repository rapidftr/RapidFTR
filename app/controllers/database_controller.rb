class DatabaseController < ApplicationController
  before_action :restrict_to_nonproduction

  def delete_data
    data_type   = params[:data_type]
    model_class = data_type.camelize.constantize

    docs = model_class.database.documents["rows"].map do |doc|
      {"_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true} unless doc["id"].include? "_design"
    end.compact
    RestClient.post "#{model_class.database.root}/_bulk_docs", {:docs => docs}.to_json, "Content-type" => "application/json" unless docs.empty?

    render :text => "Deleted all #{data_type} documents"
  end

  def reset_fieldworker
    user = User.find_by_user_name('field_worker')
    user.destroy if user
    role = Role.find_by_name('Registration Worker')
    user = User.create!("user_name" => "field_worker",
                        "password" => "field_worker",
                        "password_confirmation" => "field_worker",
                        "full_name" => "Field Worker",
                        "email" => "field_worker@rapidftr.com",
                        "disabled" => "false",
                        "organisation" => "N/A",
                        "role_ids" => [role.id])

    render :text => "Field Worker Reset: #{user.user_name}"
  end

  private

  def restrict_to_nonproduction
    raise CanCan::AccessDenied unless Rails.env.android? || Rails.env.test? || Rails.env.development? || Rails.env.cucumber?
  end
end
