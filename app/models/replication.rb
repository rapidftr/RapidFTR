class Replication < CouchRestRails::Document
  module Status
    TRIGGERED = 'triggered'
    COMPLETED = 'completed'
    ERROR     = 'error'
  end

  include CouchRest::Validation
  include RapidFTR::Model

  use_database :replication_config

  property :remote_url
  property :description

  validates_presence_of :remote_url
  validates_presence_of :description
  validates_with_method :remote_url, :method => :validate_remote_url

  before_save   :normalize_remote_url
  after_save    :start_replication
  before_destroy :stop_replication

  def start_replication
    replicator.save_doc push_config if target && !push_doc
    replicator.save_doc pull_config if target && !pull_doc
    true
  end

  def stop_replication
    replicator.delete_doc push_doc if push_doc
    replicator.delete_doc pull_doc if pull_doc
    true
  end

  def restart_replication
    stop_replication
    start_replication
  end

  def push_id
    "push-" + self["_id"].downcase.parameterize.dasherize
  end

  def pull_id
    "pull-" + self["_id"].downcase.parameterize.dasherize
  end

  def push_config
    { "source" => source, "target" => target, "_id" => push_id, "rapidftr_ref_id" => self["_id"], "rapidftr_env" => Rails.env }
  end

  def pull_config
    { "source" => target, "target" => source, "_id" => pull_id, "rapidftr_ref_id" => self["_id"], "rapidftr_env" => Rails.env }
  end

  def push_doc
    replicator.get push_id rescue nil
  end

  def pull_doc
    replicator.get pull_id rescue nil
  end

  def push_state
    push_doc['_replication_state'] rescue nil
  end

  def pull_state
    pull_doc['_replication_state'] rescue nil
  end

  def timestamp
    push_timestamp = push_doc['_replication_state_time'].to_datetime rescue nil
    pull_timestamp = pull_doc['_replication_state_time'].to_datetime rescue nil
    (push_timestamp && pull_timestamp && push_timestamp > pull_timestamp) ? push_timestamp : (pull_timestamp || push_timestamp)
  end

  def status
    triggered? ? Status::TRIGGERED : completed? ? Status::COMPLETED : Status::ERROR
  end

  def triggered?
    push_state == Status::TRIGGERED || pull_state == Status::TRIGGERED
  end

  def completed?
    push_state == Status::COMPLETED && pull_state == Status::COMPLETED
  end

  def error?
    push_state == Status::ERROR || pull_state == Status::ERROR
  end

  def source
    Child.database.name
  end

  def target
    begin
      uri = URI.parse self.class.normalize_url remote_config["target"]
      uri.host = remote_uri.host if ['localhost', '127.0.0.1', '::1'].include? uri.host
      uri.to_s
    rescue
      nil
    end
  end

  def remote_uri
    uri = URI.parse self.class.normalize_url remote_url
    uri.path = '/'
    uri
  end

  def self.configuration
    { :target => Child.database.root }
  end

  def self.normalize_url(url)
    url = "http://#{url}" unless url.include? '://'
    url = "#{url}/"       unless url.ends_with? '/'
    url
  end

  private

  def validate_remote_url
    begin
      raise unless remote_uri.is_a?(URI::HTTP) or remote_uri.is_a?(URI::HTTPS)
      true
    rescue
      [false, "Please enter a proper URL, e.g. http://<server>:<port>"]
    end
  end

  def normalize_remote_url
    self.remote_url = remote_uri.to_s
  end

  def remote_config
    uri = remote_uri
    uri.path = Rails.application.routes.url_helpers.configuration_replications_path

    response = Net::HTTP.post_form uri, {}
    JSON.parse response.body
  end

  def replicator
    COUCHDB_SERVER.database('_replicator')
  end

end
