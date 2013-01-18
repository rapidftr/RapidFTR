require 'erb'
require 'zip/zip'

namespace :windows do
  task :package do
    root_path     = File.expand_path '../..', File.dirname(__FILE__)
    target_path   = File.join File.dirname(__FILE__), 'windows'
    zip_file      = File.join target_path, 'Codebase.jar'
    includes      = %w(app/**/* config/**/* db/**/* lib/**/* public/**/* script/**/* vendor/**/* config.ru Gemfile Gemfile.lock LICENSE Rakefile README README.md)
    excludes      = %w(*.exe **/.* **/.git*)

    Dir.chdir root_path do
      FileUtils.rm zip_file, :force => true
      Zip::ZipFile.open zip_file, Zip::ZipFile::CREATE do |z|
        Dir.glob(includes).each do |file|
          z.add file, file unless excludes.any? { |exclude| File.fnmatch? exclude, file }
        end
      end
    end
  end

  task :reset => %w( couchdb:delete couchdb:create db:seed db:migrate )
end
