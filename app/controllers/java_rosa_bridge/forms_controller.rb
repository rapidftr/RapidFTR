# Provides a bridge allowing us to support the javarosa
# client/server protocol (see http://bitbucket.org/javarosa/javarosa/wiki/FormListAPI) 
module JavaRosaBridge
class FormsController < ApplicationController
  skip_before_filter :check_authentication
  skip_before_filter :verify_authenticity_token

  def index
    @available_forms = {:rapid_ftr => 'RapidFTR'}
    respond_to do |format|
      format.xml
    end
  end
  
  def show
    respond_to do |format|
      format.xml
    end
  end

  def submission
    logger.debug( params.inspect )
    file_contents = params['xml_submission_file'].read
    logger.debug( file_contents )
    raise 'TODO'
  end


end
end
