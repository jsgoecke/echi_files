Gem::Specification.new do |s|
  s.name = "echi_files"
  s.version = "0.1.0"
  s.summary = "Ruby Library for Processing Avaya ECHI Files"
  s.description = "Ruby Library for processing External Call History (ECHI) files from the Avaya CMS"
  s.authors = ["Jason Goecke"]
  s.email = ["jason@goecke.net"]
 
  s.files = ["lib/echi_files.rb", 
             "lib/extended-definition.yml",
             "lib/standard-definition.yml", 
             "LICENSE", 
             "README.textile", 
             "echi_files.gemspec"]
  s.require_paths = ["lib"]
 
  s.add_dependency("fastercsv", ">=", "1.4.0")
end