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
  property :user_name
  property :crypted_password
  property :needs_reindexing, :cast_as => :boolean, :default => false

  attr_accessor :password

  validates_presence_of :remote_url
  validates_presence_of :description
  validates_presence_of :user_name
  validates_presence_of :password
  validates_with_method :remote_url, :method => :validate_remote_url

  before_save   :normalize_remote_url, :encrypt_password
  after_save    :start_replication
  before_destroy :stop_replication

  def start_replication
    replicator.save_doc push_config if target && !push_doc
    replicator.save_doc pull_config if target && !pull_doc

    self.needs_reindexing = true
    save_without_callbacks
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

  def check_status_and_reindex
    if needs_reindexing? and (completed? or error?)
      Rails.logger.info "Replication complete, triggering reindex"
      trigger_local_reindex
      trigger_remote_reindex
    end
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
      uri.scheme = remote_uri.scheme
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

  def self.configuration(username, password)
    uri = URI.parse(Child.database.root)
    { :target => "http://#{username}:#{password}@"+uri.host+":"+COUCHDB_CONFIG[:https_port].to_s+uri.path}
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
    uri.path = Rails.application.routes.url_helpers.reindex_children_path
    Net::HTTP.get uri
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
    post_params = {:user_name => self.user_name, :password => self.crypted_password}

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

  def encrypt_password
    self.crypted_password = self.password
  end

end
