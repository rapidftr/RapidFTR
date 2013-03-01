class Replication < CouchRestRails::Document
  MODELS_TO_SYNC = [ Role, Child, User ]
  STABLE_WAIT_TIME = 2.minutes

  include CouchRest::Validation
  include RapidFTR::Model

  use_database :replication_config

  property :remote_app_url
  property :remote_couch_config, :cast_as => 'Hash', :default => {}

  property :description
  property :username
  property :password
  property :needs_reindexing, :cast_as => :boolean, :default => true

  validates_presence_of :remote_app_url
  validates_presence_of :description
  validates_presence_of :username
  validates_presence_of :password
  validates_with_method :remote_app_url, :method => :validate_remote_app_url
  validates_with_method :save_remote_couch_config

  before_save   :normalize_remote_app_url
  before_save   :mark_for_reindexing

  after_save    :start_replication
  before_destroy :stop_replication

  def start_replication
    stop_replication

    build_configs.each do |config|
      replicator.save_doc config
    end

    unless needs_reindexing?
      self.needs_reindexing = true
      save_without_callbacks
    end

    true
  end

  def stop_replication
    fetch_configs.each do |config|
      replicator.delete_doc config
    end
    invalidate_fetch_configs
  end

  def check_status_and_reindex
    if needs_reindexing? and !active?
      Rails.logger.info "Replication complete, triggering reindex"
      trigger_local_reindex
      trigger_remote_reindex
    end
  end

  def mark_for_reindexing
    self.needs_reindexing = true
  end

  def timestamp
    fetch_configs.collect { |config| config["_replication_state_time"].to_datetime rescue nil }.compact.max
  end

  def statuses
    fetch_configs.collect { |config| config["_replication_state"] || 'triggered' }
  end

  def active?
    statuses.include?("triggered") || (timestamp && timestamp > STABLE_WAIT_TIME.ago)
  end

  def success?
    statuses.uniq == [ "completed" ]
  end

  def status
    active? ? "triggered" : success? ? "completed" : "error"
  end

  def remote_app_uri
    uri = URI.parse self.class.normalize_url remote_app_url
    uri.path = "/"
    uri
  end

  def remote_couch_uri(path = "")
    uri = URI.parse remote_couch_config["target"]
    uri.path = "/#{path}"
    uri.user = username if username
    uri.password = password if password
    uri
  end

  def push_config(model)
    target = remote_couch_uri remote_couch_config["databases"][model.to_s]
    { "source" => model.database.name, "target" => target.to_s, "rapidftr_ref_id" => self["_id"], "rapidftr_env" => Rails.env }
  end

  def pull_config(model)
    target = remote_couch_uri remote_couch_config["databases"][model.to_s]
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
    uri = remote_app_uri
    uri.path = Rails.application.routes.url_helpers.reindex_children_path
    Net::HTTP.get uri
  end

  def invalidate_fetch_configs
    @fetch_configs = nil
    true
  end

  def validate_remote_app_url
    begin
      raise unless remote_app_uri.is_a?(URI::HTTP) or remote_app_uri.is_a?(URI::HTTPS)
      true
    rescue
      [false, "Please enter a proper URL, e.g. http://<server>:<port>"]
    end
  end

  def normalize_remote_app_url
    self.remote_app_url = remote_app_uri.to_s
  end

  def save_remote_couch_config
    begin
      uri = remote_app_uri
      uri.path = Rails.application.routes.url_helpers.configuration_replications_path
      post_params = {:user_name => self.username, :password => self.password}

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

      self.remote_couch_config = JSON.parse response.body
      true
    rescue => e
      [false, "The URL/Username/Password that you entered is incorrect"]
    end
  end

  def replicator
    @replicator ||= COUCHDB_SERVER.database('_replicator')
  end

  def replicator_docs
    replicator.documents["rows"].map { |doc| replicator.get doc["id"] unless doc["id"].include? "_design" }.compact
  end

end
