class DatabaseController < ApplicationController

  def delete_data
    raise "Database operation not allowed" unless (Rails.env.android? || Rails.env.test? || Rails.env.development? || Rails.env.cucumber?)

    data_type   = params[:data_type]
    model_class = data_type.camelize.constantize

    docs = model_class.database.documents["rows"].map { |doc|
      { "_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true } unless doc["id"].include? "_design"
    }.compact
    RestClient.post "#{model_class.database.root}/_bulk_docs", { :docs => docs }.to_json, { "Content-type" => "application/json" } unless docs.empty?

    render text: "Deleted all #{data_type} documents"
  end

end