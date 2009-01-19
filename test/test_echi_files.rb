require 'rubygems'
require 'lib/echi_files'
require 'test/unit'

class EchiFiles_Test < Test::Unit::TestCase
  
  def setup
    #Provide a filename to process as an argument on the commandline
    binary_file = File.open(File.expand_path("test/example_binary_file"))
    ascii_file = File.open(File.expand_path("test/example_ascii_file"))
    @proper_unstripped = YAML::load(File.open(File.expand_path("test/proper_unstripped.yml")))
    @proper_stripped = YAML::load(File.open(File.expand_path("test/proper_stripped.yml")))
    @proper_ascii = YAML::load(File.open(File.expand_path("test/proper_ascii.yml")))

    #Create a new EchiFiles object
    echi_handler = EchiFiles.new

    #Use this to process a binary file
    file_type = 'BINARY'
    format = 'EXTENDED'
    #In some cases the extra_byte is needed
    extra_byte = true
    @binary_data = echi_handler.process_file(binary_file, file_type, format, extra_byte)
    #If you need to strip in characters from the asaiuui field
    @stripped_data = Array.new
    @binary_data.each do |data|
      @stripped_data << echi_handler.strip_special_characters(data, [ "asaiuui" ], [ 0 ])
    end
    
    #Use this to process an ASCII file
    file_type = 'ASCII'
    format = 'EXTENDED'
    @ascii_data = echi_handler.process_file(ascii_file, file_type, format, extra_byte)
  end
  
  def teardown
  end
  
  #Test that processing a binary file works
  def test_binary_file
    assert_equal(@proper_unstripped, @binary_data)
  end
  
  #Test that characters are stripped properly
  def test_stripping_characters
    assert_equal(@proper_stripped, @stripped_data)
  end
  
  #Test that processing an ascii file works
  def test_ascii_file
    assert_equal(@ascii_data, @proper_ascii)
  end
end
