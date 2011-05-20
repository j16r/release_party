Gem::Specification.new do |s|
  s.name                      = 'release_party'
  s.version                   = '0.0.1'
  s.authors                   = ['John Barker']
  s.date                      = '2011-05-18'
  s.homepage                  = 'https://github.com/excepttheweasel/release_party'
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.description               = 'Perform a number of common post deployment tasks such as delivering pivotal stories, sending out a release email, notifying campfire.'
  s.summary                   = 'Celebrate releases'
  s.email                     = 'jebarker@gmail.com'
  s.extra_rdoc_files          = []
  s.files                     = Dir["lib/**/*.rb"]

  s.add_runtime_dependency    'capistrano',        '>= 2.6.0'
  s.add_runtime_dependency    'pivotal-tracker',   '>= 0.2.0'
  s.add_runtime_dependency    'grit',              '>= 2.4.1'
  s.add_runtime_dependency    'mail',              '>= 2.1.0'
  s.add_runtime_dependency    'capistrano_colors', '>= 0'
  s.add_runtime_dependency    'colored',           '>= 0'
end
