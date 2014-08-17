module RapidFTR
  module I18nSetup
    def self.reset_definitions
      Dir[File.join(Rails.root, 'db', 'couch', 'i18n', 'seeds', '*.yml')].each do |file|
        locale = File.basename(file, ".*")
        data   = YAML.load(File.open(file))
        I18n.backend.store_translations locale, data[locale]
      end
    end
  end
end
