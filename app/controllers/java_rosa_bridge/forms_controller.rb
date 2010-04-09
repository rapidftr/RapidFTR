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

    params = transform_xform_doc_to_params_hash(file_contents)
    child = Child.new_with_user_name( 'javarosa_user', params )
    child.save!

    redirect_to child_url( child ), :status => 201
  end



  private

  def transform_xform_doc_to_params_hash( xml )
    params = {}
    doc = Nokogiri::XML( xml )
    doc.search('xform/*').each do |xform_node|
      params[xform_node.name] = xform_node.text
    end
    params
  end


end
end
