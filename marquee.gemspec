require_relative "lib/marquee/version"

Gem::Specification.new do |spec|
  spec.name        = "marquee"
  spec.version     = Marquee::VERSION
  spec.authors     = [ "tylercschneider" ]
  spec.email       = [ "tylercschneider@gmail.com" ]
  spec.homepage    = "https://github.com/tylercschneider/marquee"
  spec.summary     = "A page framework engine for Rails SaaS apps."
  spec.description = "Marquee provides page registration, routing, versioning, A/B testing, funnel tracking, lead capture, and an admin UI for Rails applications. Pages are code — ERB templates in your host app — and Marquee provides the infrastructure around them."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tylercschneider/marquee"
  spec.metadata["changelog_uri"] = "https://github.com/tylercschneider/marquee/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1"
end
