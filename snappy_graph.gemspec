$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "snappy_graph/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "snappy_graph"
  s.version     = SnappyGraph::VERSION
  s.authors     = ["Peter Leppers"]
  s.summary     = "A javascript library for creating data visualization"
  s.description = "A javascript library for creating data visualization"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

end
