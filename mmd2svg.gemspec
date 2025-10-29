# frozen_string_literal: true

require_relative 'lib/mmd2svg/version'

Gem::Specification.new do |spec|
  spec.name = 'mmd2svg'
  spec.version = Mmd2svg::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'Convert Mermaid diagrams to SVG'
  spec.description = 'A command-line tool and library to convert Mermaid diagram definitions into SVG files.'
  spec.homepage = 'https://github.com/ydah/mmd2svg'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .github/])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'puppeteer-ruby', '~> 0.45'
  spec.add_dependency 'thor', '~> 1.3'
end
