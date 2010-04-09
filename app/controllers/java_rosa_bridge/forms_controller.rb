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
    form_sections = get_form_sections
    @fields = form_sections.map(&:fields).flatten
    respond_to do |format|
      format.xml
    end
  end

  def submission
    submitter_name = determine_user_name
    if submitter_name.nil?
      request_http_basic_authentication
      return
    end

    logger.debug( params.inspect )
    file_contents = params['xml_submission_file'].read
    logger.debug( file_contents )

    param_hash = transform_xform_doc_to_params_hash(file_contents)
    child = Child.new_with_user_name( submitter_name, param_hash )

    if param_hash['current_photo_key']
      logger.debug( 'adding photo to child record' )
      child.photo = params[ param_hash['current_photo_key'] ] 
    end

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

  def determine_user_name
    return 'anon_javarosa_user' if ActionController::HttpAuthentication::Basic.authorization(request).nil?
    
    user = authenticate_using_basic_auth
    (user && user.user_name) || nil
  end


  def authenticate_using_basic_auth
    authenticate_with_http_basic do |user_name, password|
      user = User.find_by_user_name(user_name)
      return nil if user.nil?
      user.authenticate(password) ? user : nil
    end
  end

  def get_form_sections
    forms = Templates.child_form_section_names.map do |section_name|
      template = Templates.get_template(section_name)
      FormSection.create_form_section_from_template(section_name,template)
    end
    #forms << create_relations_section_for( child )
    forms.compact
  end


end
end
