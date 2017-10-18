require_relative "./lib/query_set"

Gem::Specification.new do |s|
  s.name     = "query_set"
  s.summary  = "QuerySet"
  s.version  = QuerySet::VERSION
  s.authors  = ["Steve Weiss"]
  s.email    = ["weissst@mail.gvsu.edu"]
  s.homepage = "https://github.com/sirscriptalot/query_set"
  s.license  = "MIT"
  s.files    = `git ls-files`.split("\n")

  s.add_development_dependency "cutest", "~> 1.2"
end
