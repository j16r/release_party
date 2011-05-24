Gem::Specification.new do |spec|
  spec.name                       = 'release_party'
  spec.version                    = '0.0.2'
  spec.authors                    = ['John Barker']
  spec.date                       = '2011-05-24'
  spec.homepage                   = 'https://github.com/excepttheweasel/release_party'
  spec.license                    = 'MIT'
  spec.required_rubygems_version  = Gem::Requirement.new("> 1.3.1") if spec.respond_to? :required_rubygems_version=
  spec.description                = 'Perform a number of common post deployment tasks such as delivering pivotal stories, sending out a release email, notifying campfire.'
  spec.summary                    = 'Celebrate releases!'
  spec.email                      = 'jebarker@gmail.com'
  spec.extra_rdoc_files           = []
  spec.files                      = Dir["lib/**/*.rb"]

  spec.add_runtime_dependency     'capistrano',        '>= 2.6.0'
  spec.add_runtime_dependency     'capistrano_colors', '>= 0'
  spec.add_runtime_dependency     'colored',           '>= 0'

  spec.add_development_dependency 'rake',              '~> 0.8.7'
  spec.add_development_dependency 'rspec',             '>= 2.5.0'
  spec.add_development_dependency 'rr',                '~> 1.0.2'
  spec.add_development_dependency 'bundler',           '>= 1.0.9'
  spec.add_development_dependency 'rcov',              '>= 0'
  spec.add_development_dependency 'capistrano-spec'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'haml'
  spec.add_development_dependency 'sass'
  spec.add_development_dependency 'pivotal-tracker',   '>= 0.2.0'
  spec.add_development_dependency 'mail',              '>= 2.1.0'
  spec.add_development_dependency 'grit',              '>= 2.4.1'
  spec.add_development_dependency 'tinder'
end
