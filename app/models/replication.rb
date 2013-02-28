class Replication < CouchRestRails::Document
  MODELS_TO_SYNC = [ Role, Child, User ]

  include CouchRest::Validation
  include RapidFTR::Model

  use_database :replication_config

  property :remote_url
  property :description
  property :user_name
  property :password
  property :needs_reindexing, :cast_as => :boolean, :default => false

  validates_presence_of :remote_url
  validates_presence_of :description
  validates_presence_of :user_name
  validates_presence_of :password
  validates_with_method :remote_url, :method => :validate_remote_url

  before_save   :normalize_remote_url
  after_save    :start_replication
  after_save    :invalidate_fetch_configs
  before_destroy :stop_replication

  def start_replication
    build_configs.each do |config|
      replicator.save_doc config
    end

    self.needs_reindexing = true
    save_without_callbacks
  end

  def stop_replication
    fetch_configs.each do |config|
      replicator.delete_doc config
    end
    invalidate_fetch_configs
    true
  end

  def restart_replication
    stop_replication
    start_replication
  end

  def check_status_and_reindex
    if needs_reindexing? and !active?
      Rails.logger.info "Replication complete, triggering reindex"
      trigger_local_reindex
      trigger_remote_reindex
    end
  end

  def timestamp
    fetch_configs.collect { |config| config["_replication_state_time"].to_datetime rescue nil }.compact.max
  end

  def statuses
    fetch_configs.collect { |config| config["_replication_state"] || 'triggered' }
  end

  def active?
    statuses.include? "triggered"
  end

  def success?
    statuses.uniq == [ "completed" ]
  end

  def status
    active? ? "triggered" : success? ? "completed" : "error"
  end

  def target
    begin
      uri = URI.parse self.class.normalize_url remote_config["target"]
      uri.host = remote_uri.host if ['localhost', '127.0.0.1', '::1'].include? uri.host
      uri.scheme = remote_uri.scheme
      uri.to_s
    rescue
      nil
    end
  end

  def remote_uri
    uri = URI.parse self.class.normalize_url remote_url
    uri.path = "/"
    uri
  end

  def remote_couch_uri(path = "")
    uri = URI.parse remote_config["target"]
    uri.path = "/#{path}"
    uri
  end

  def push_config(model)
    target = remote_couch_uri remote_config["databases"][model.to_s]
    { "source" => model.database.name, "target" => target.to_s, "rapidftr_ref_id" => self["_id"], "rapidftr_env" => Rails.env }
  end

  def pull_config(model)
    target = remote_couch_uri remote_config["databases"][model.to_s]
    { "source" => target.to_s, "target" => model.database.name, "rapidftr_ref_id" => self["_id"], "rapidftr_env" => Rails.env }
  end

  def build_configs
    self.class.models_to_sync.map do |model|
      [ push_config(model), pull_config(model) ]
    end.flatten
  end

  def fetch_configs
    @fetch_configs ||= replicator_docs.select { |rep| rep["rapidftr_ref_id"] == self.id }
  end

  def self.models_to_sync
    MODELS_TO_SYNC
  end

  def self.couch_config
    uri = URI.parse(Child.database.root)
    uri.scheme = 'https'
    uri.port = COUCHDB_CONFIG[:https_port]
    uri.user = nil
    uri.password = nil
    uri.path = '/'

    {
      :target => uri.to_s,
      :databases => models_to_sync.inject({}) { |result, model|
        result[model.to_s] = model.database.name
        result
      }
    }
  end

  def self.normalize_url(url)
    url = "http://#{url}" unless url.include? '://'
    url = "#{url}/"       unless url.ends_with? '/'
    url
  end

  def self.authenticate_with_internal_couch_users(username, password)
    RestClient.post COUCHDB_SERVER.uri+'/_session', 'name='+username+'&password='+password,{:content_type => 'application/x-www-form-urlencoded'}
  end

  def self.schedule(scheduler)
    scheduler.every("5m") do
      begin
        Rails.logger.info "Checking Replication Status..."
        Replication.all.each(&:check_status_and_reindex)
      rescue => e
        Rails.logger.error "Error checking replication status"
        e.backtrace.each { |line| Rails.logger.error line }
      end
    end
  end

  private

  def trigger_local_reindex
    Child.reindex!
    self.needs_reindexing = false
    save_without_callbacks
  end

  def trigger_remote_reindex
    uri = remote_uri
    uri.user = user_name if user_name
    uri.password = password if password
    uri.path = Rails.application.routes.url_helpers.reindex_children_path
    Net::HTTP.get uri
  end

  def invalidate_fetch_configs
    @fetch_configs = nil
    true
  end

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

    if uri.scheme == "http"
      response = Net::HTTP.post_form uri, post_params
    else
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(post_params)
      response = http.start{|req| req.request(request)}
    end
    JSON.parse response.body
  end

  def replicator
    @replicator ||= COUCHDB_SERVER.database('_replicator')
  end

  def replicator_docs
    replicator.documents["rows"].map { |doc| replicator.get doc["id"] unless doc["id"].include? "_design" }.compact
  end

end
