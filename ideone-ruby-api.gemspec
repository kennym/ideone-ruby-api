# frozen_string_literal: true

require_relative "lib/ideone/version"

Gem::Specification.new do |spec|
  spec.name = "ideone-ruby-api"
  spec.version = Ideone::Version::STRING
  spec.authors = ["Kenny Meyer"]
  spec.email = ["kenny@kennymeyer.net"]

  spec.summary = "Ruby binding for the Ideone API"
  spec.description = "A Ruby binding for the Ideone SOAP API (online compiler / pastebin)."
  spec.homepage = "https://github.com/kennym/ideone-ruby-api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/master"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*.rb", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.17"
  spec.add_dependency "cgi", "~> 0.5" # Ruby 4.0 removed cgi from default gems; Savon/Gyoku still need it

  spec.add_development_dependency "minitest", "~> 6.0"
  spec.add_development_dependency "rake", "~> 13.4"
  spec.add_development_dependency "webmock", "~> 3.26"
end
