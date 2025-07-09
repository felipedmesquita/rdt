Gem::Specification.new do |s|
  s.name        = "rdt"
  s.version     = "0.1.0"
  s.summary     = "Ruby Data Tool"
  s.description = "SQL-based data modeling for Rails applications and Postgres"
  s.authors     = ["Felipe Mesquita"]
  s.email       = "felipemesquita@hey.com"
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    = "https://github.com/felipedmesquita/dbt"
  s.license     = "MIT"

  s.add_dependency 'dagwood', '~> 1.0'
  s.add_dependency 'zeitwerk'
  s.add_dependency 'activerecord', '>= 6.0'
end
