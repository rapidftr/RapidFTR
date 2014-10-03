module Api
  class PotentialMatchesController < ApiController
    def index
      authorize! :read, PotentialMatch
      potential_matches = PotentialMatch.all.all

      unless params[:updated_after].nil?
        updated_after = Time.parse(URI.decode(params[:updated_after]))
        potential_matches.select! { |pm| pm.updated_at >= updated_after }
      end
      locations = potential_matches.map { |pm| {:location => api_potential_match_url(pm.id)} }
      render(:json => locations)
    end

    def show
      authorize! :read, PotentialMatch
      render :json => PotentialMatch.find(params[:id])
    end
  end
end
