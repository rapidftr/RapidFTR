class Replication < CouchRestRails::Document
  include CouchRest::Validation
  include RapidFTR::Model

  use_database :replication_config

  property :description
  property :host
  property :port
  property :database_name

  validates_presence_of :description
  validates_presence_of :host
  validates_presence_of :port
  validates_numericality_of :port, :only_integer => true
  validates_presence_of :database_name

  after_save    :start_replication
  after_destroy :stop_replication

  def url
    "http://#{host}:#{port}/#{database_name}"
  end

  def start_replication
    replicator.save_doc :source => me, :target => url, "_id" => push_id, "rapidftr_ref_id" => self["_id"] unless push_config
    replicator.save_doc :source => url, :target => me, "_id" => pull_id, "rapidftr_ref_id" => self["_id"] unless pull_config
  end

  def stop_replication
    replicator.delete_doc push_config if push_config
    replicator.delete_doc pull_config if pull_config
  end

  def restart_replication
    stop_replication
    start_replication
  end
  
  def push_id
    "#{me} to #{url}".downcase.parameterize.dasherize
  end

  def pull_id
    "#{url} to #{me}".downcase.parameterize.dasherize
  end

  def push_config
    replicator.get push_id rescue nil
  end

  def pull_config
    replicator.get pull_id rescue nil
  end

  def status
    triggered? ? 'triggered' : completed? ? 'completed' : 'error'
  end

  def triggered?
    push_state == 'triggered' || pull_state == 'triggered'
  end

  def completed?
    push_state == 'completed' && pull_state == 'completed'
  end

  def error?
    push_state == 'error' || pull_state == 'error'
  end

  def push_state
    push_config['_replication_state'] rescue nil
  end

  def pull_state
    pull_config['_replication_state'] rescue nil
  end

  private

  def me
    "rapidftr_child_#{Rails.env.downcase}"
  end

  def replicator
    COUCHDB_SERVER.database('_replicator')
  end

end
