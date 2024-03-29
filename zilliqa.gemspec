
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "zilliqa/version"

Gem::Specification.new do |spec|
  spec.name          = "zilliqa"
  spec.version       = Zilliqa::VERSION
  spec.authors       = ["snuff" ,"cenyongh"]
  spec.email         = ["vladimir@protasevi.ch", "cenyongh@gmail.com"]

  spec.summary       = %q{Zilliqa — Zilliqa Ruby Blockchain Library}
  spec.description   = %q{Zilliqa -- Zilliqa Ruby Blockchain Library}
  spec.homepage      = "https://github.com/mechanizm/zilliqa"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mechanizm/zilliqa"
    spec.metadata["changelog_uri"] = "https://github.com/mechanizm/zilliqa"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", ">= 2.2.33"
  spec.add_development_dependency "rake", "~> 13.0"
  # FIXME starting with 5.16 minitest supports kwargs in mocks,
  # and that breaks our tests, e.g in contract/contract_factory_test.rb:186,
  # where we expect hash as mock argument, but minitest treat this hash as kwargs
  spec.add_development_dependency "minitest", "5.15"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_dependency "ruby-bitcoin-secp256k1"
  spec.add_dependency "scrypt"
  spec.add_dependency "pbkdf2-ruby"
  spec.add_dependency "jsonrpc-client"
  spec.add_dependency 'google-protobuf'
  spec.add_dependency 'bitcoin-ruby'
end
