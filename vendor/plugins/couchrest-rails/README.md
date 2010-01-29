# CouchRest-Rails

A Rails plugin for connecting to and working with a [CouchDB](http://couchdb.apache.org) document-oriented database via the [CouchRest](http://github.com/jchris/couchrest) RESTful CouchDB client.

Specifically, this plugin provides the following utilities:

* Initializer for use with a couchdb.yml configuration file
* CouchDB-specific rake tasks (database creation, deletion, fixture loading, views synchronization)
* CouchDB-specific fixtures
* Setup and teardown helpers for spec'ing and testing
* A paper-thin wrapper around CouchRest::ExtendedDocument
* Support for multiple CouchDB databases per application
* Optional support for Lucene full-text indexing and searching of your CouchDB databases and documents

This plugin does not interfere with the traditional relational database backend, so you can use that as a datastore alongside CouchDB if you want.  (In fact, you'll have to unwire the requirement for a relational database if you don't want to use one.)

This plugin assumes some knowledge of CouchDB and its important differences from conventional Rails data storage (RDBMS) options.  See [the CouchDB site](http://couchdb.apache.org) for more information.  

## Requirements

* [CouchRest gem](http://github.com/jchris/couchrest)
* [Validatable gem](http://validatable.rubyforge.org/)
* [JSON gem](http://json.rubyforge.com)
* [RSpec](http://github.com/dchelimsky/rspec) BDD framework (optional - for running plugin specs)
* [RSpec-Rails](http://github.com/dchelimsky/rspec-rails) library (optional - for running plugin specs)
* Lucene (optional) for full text searching of CouchDB documents

## Installation

Install with the native Rails plugin installation script:

    script/plugin install git://github.com/hpoydar/couchrest-rails.git

Or simply add to vendor/plugins and generate the files you need:

    script/generate couch_rest_rails
    
The plugin creates two folders:

* `db/couch/` - For storing CouchDB database information map and reduce functions (views)
* `test/fixtures/couch` - for storing and loading CouchDB fixtures (yaml)

These paths can be customized in an initializer or environment configuration file:

    CouchRestRails.fixtures_path  = 'custom/path/to/your/fixtures/from/app/root'
    CouchRestRails.views_path     = 'custom/path/to/your/views/from/app/root'
    
The installation process will also create a `config/couchdb.yml` file for customizing your configuration.
    
## Usage    

### Configuration

The `couchdb.yml` file can be customized to support the specifics of your particular CouchDB installation.  Since multiple databases per application are supported, it is recommended that you specify a `database_prefix` for use in naming the database on the CouchDB server.  This will make it much easier to peer into your server with Sofa and figure out which databases belong to which application.

Database names are defined in the `CouchRestRails::Document` models that use them.  (See below, 'CouchRestRails document model')

### Rake tasks

Use the rake tasks to create databases, delete databases, reset databases, push views and load fixtures:

    rake couchdb:create[database]             # Create a CouchDB database defined in config/couchdb.yml for the current environment (use no database argument to use all databases defined in CouchRestRails::Document models)
    rake couchdb:delete[database]             # Deletes a CouchDB database for the current RAILS_ENV (use no database argument to use all databases defined in CouchRestRails::Document models)
    rake couchdb:fixtures:load[database]      # Load fixtures into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)
    rake couchdb:lucene:push[database]        # Push Lucene views into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)
    rake couchdb:views:push[database]         # Push views into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)
    rake doc:plugins:couchrest-rails          # Generate documentation for the couchrest-rails plugin
    
### CouchRestRails document model

For models, inherit from CouchRestRails::Document, which hooks up CouchRest::ExtendedDocument to your CouchDB backend and includes the [Validatable](http://validatable.rubyforge.org/) module:

    class YourCouchDocument < CouchRestRails::Document
      use_database :database_name

      property  :email
      property  :question
      property  :answer
      property  :rating

      timestamps!

      view_by :email

      validates_presence_of :question
      validates_numericality_of :rating

      ...

    end

Make sure you define your database in the model with the `use_database :<database_name>` directive.

See the CouchRest documentation and specs for more information about CouchRest::ExtendedDocument. (The views defined here are in addition to the ones you can manually set up and push via rake in db/couch/views.)

### CouchDB views

Custom views--outside of the ones defined in your CouchRestRails::Document models--that you want to push up to the CouchDB database/server instance should be in the following format:

    db/couch/<database_name>/views
                               |-- <design_document_name>
                                   |-- <view_name>
                                       |-- map.js
                                       `-- reduce.js

Push up your views via rake (`rake couchdb:views:push`) or within your code or console (`CouchRestRails::Views.push`).

    
### Tests, specs and fixtures
    
For testing or spec'ing, use these helpers to setup and teardown a test database with fixtures:

    CouchRestRails::Tests.setup
    CouchRestRails::Tests.teardown
    
There are also some simple matchers you can can use to spec validations.  See `spec/lib/matchers`.

You can store fixtures as Yaml files in the following path pattern:

    test/fixtures/couch/<database_name>.yml
                           
You can customize this path in an initializer or environment file:

    CouchRestRails.fixtures_path = 'custom/path/to/your/fixtures'

#### Rails integration unit testing 

Create fixture file by via rake (`rake couchdb:fixtures:dump[<database_name>]`) or within your code or console (`CouchRestRails::Fixtures.dump[<database_name>]`).

Add fixtures to rails test:

    class RailsTest < Test::Unit::TestCase
      couchdb_fixtures :<database_name>

      ...
    end

### Lucene

If you want to support Lucene full-text searching of CouchDB documents, enable support for it in an initializer or environment configuration file:

    CouchRestRails.use_lucene  = true
    
The Lucene design documents per database are stored alongside the views:
    
    db/couch/<database_name>/lucene
                               |-- <design_document_name>
                                   |-- <lucene_search>.js
                                   |-- <lucene_search>.js
                                   |-- ...

You can also customize this path:

    CouchRestRails.lucene_path = 'custom/path/to/your/lucene/docs/from/app/root'

Push up your lucene doc via rake (`rake couchdb:lucence:push`) or within your code or console (`CouchRestRails::Lucene.push`).

## Further development and testing

To run the test suite, you'll need rspec installed with rspec-rails library enabled for the host application. You can run the tests in the following way:

    <rails_root>$ rake spec:plugins
    <plugin_root>$ rake spec
    <plugin_root>$ autospec
    
(The latter requires the ZenTest gem)

_Please don't submit any pull requests with failing specs_

### TODO 

* Roll up CouchRest::ExtendedDocument, since it might be deprecated from CouchRest (see CouchRest raw branch)
* A persistent connection object? Keep-alive?
* Hook into Rails logger to display times for CouchDB operations
* Mechanism for better view testing?
* Restful model/controller/test/spec generator
* Error class for CouchRestRails::Document with I18n support
* Support a default database for all CouchRestRails::Document models
* Gemify
* Add more parseable options to couchdb.yml

## Contributors / Thanks

* Arnaud Berthomier
* Dave Farkas
* Adam Keyes
* Glenn Rempe
* John Wood


## License

Copyright (c) Henry Poydar, released under the MIT license
