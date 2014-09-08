module Api
  class PotentialMatchesController < ApiController
    def index
      authorize! :read, PotentialMatch
      potential_matches = PotentialMatch.all.all

      unless params[:updated_after].nil?
        potential_matches.select! { |pm| pm[:updated_at] > Time.parse(params[:updated_after]) }
      end
      locations = potential_matches.map { |pm| {:location => api_potential_match_url(pm.id)} }
      render(:json => locations)
    end

    def show
      authorize! :read, PotentialMatch
      render :json => {}
    end
  end
end
