#
# Custom I18n Backend for saving translations into CouchDB
# Used for saving dynamic translations (such as when creating new forms and fields)
# Static translations are stored as-usual in yml files
#
# Each locale is stored as a single document
# So that when translation for a locale is requested for first time - the locale is cached
# And for all subsequent t() calls the cached object can be re-used
# Also, translations for a specific locale can be bulk-downloaded on a device
#
# In the current implementation, all translations are cached whether they are required or not
# In later implementations, locale documents can be cached on demand
#
# This extends the built-in Simple backend in I18n
# And overrides only two methods: load_translations and store_translations
#
# I18n tests are also re-usable! Except they use Test::Unit
# So tests for this module have to be run as:
#    ruby -Itest test/lib/i18n_backend_couch_test.rb
#
class I18nBackendCouch < I18n::Backend::Simple

  def load_translations
    locales = db.documents["rows"].map { |row| row["id"] }
    locales.each do |locale|
      translations[locale.to_sym] = db.get(locale).deep_symbolize_keys
    end
  end

  def store_translations(locale, data, options = {})
    init_translations unless initialized?
    super
    save_doc locale.to_sym
  end

  protected

  def db
    @db ||= COUCHDB_SERVER.database! db_name
  end

  def db_name
    "rapidftr_i18n_#{Rails.env}"
  end

  # Merge and save data into an existing document
  # Or create a new document
  def save_doc(locale)
    data   = translations[locale] || {}
    locale = locale.to_s
    data   = clean(deep_stringify_keys(data))

    begin
      doc = db.get(locale)
      attributes = doc.to_hash.deep_merge(data)
      data.each do |key|
        doc[key] = attributes[key]
      end
      doc.save
    rescue
      data["_id"] = locale
      db.save_doc(data)
    end
  end

  # The presence of these two attributes frequently causes CouchRest Conflicts
  def clean(data)
    data.delete "_id"
    data.delete "_rev"
    data
  end

  # Converts all symbol hash keys into Strings for merging and saving in CouchDB
  def deep_stringify_keys(data)
    data.each_with_object({}) do |(key, value), result|
      result[key.to_s] = value.is_a?(Hash) ? deep_stringify_keys(value) : value
    end
  end

end
