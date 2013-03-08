# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "zipruby"
  s.version = "0.3.6"
  s.platform = "mswin32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["winebarrel"]
  s.date = "2010-01-23"
  s.email = "sgwr_dts@yahoo.co.jp"
  s.extra_rdoc_files = ["README.txt", "zipruby.c", "LICENSE.libzip", "ChangeLog"]
  s.files = ["README.txt", "zipruby.c", "LICENSE.libzip", "ChangeLog"]
  s.homepage = "http://zipruby.rubyforge.org"
  s.rdoc_options = ["--title", "Zip/Ruby - Ruby bindings for libzip."]
  s.require_paths = ["lib/i386-mswin32"]
  s.rubyforge_project = "zipruby"
  s.rubygems_version = "1.8.25"
  s.summary = "Ruby bindings for libzip."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
