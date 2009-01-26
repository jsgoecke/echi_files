Gem::Specification.new do |s|
  s.name = "echi_files"
  s.version = "0.2.1"
  s.date = "2009-01-26"
  s.summary = "Ruby Library for Processing Avaya ECHI Files"
  s.description = "Ruby Library for processing External Call History (ECHI) files from the Avaya CMS"
  s.authors = ["Jason Goecke"]
  s.email = ["jason -at- goecke.net"]
  s.has_rdoc = false
  s.homepage = "http://jsgoecke.github.com/echi_files"
  s.rubygems_version = "1.3.1"
 
  s.files = ["lib/echi_files.rb", 
             "lib/extended-definition.yml",
             "lib/standard-definition.yml",
             "test/example_ascii_file", 
             "test/example_binary_file",
             "test/proper_ascii.yml",
             "test/proper_stripped.yml",
             "test/proper_unstripped.yml",
             "test/test_echi_files.rb",
             "History.txt",
             "LICENSE", 
             "README.textile", 
             "echi_files.gemspec"]
  s.require_paths = ["lib"]
 
  s.add_dependency("fastercsv", ">=", "1.4.0")
end