# This library is used to process Avaya CMS ECHI Files
#
# Author::    Jason Goecke  (mailto:jason@goecke.net)
# Copyright:: Copyright (c) 2009 Jason Goecke
# License::   Distributes under the MIT License
#
# This class contains the methods for processing both
# binary and ascii files from the Avaya CMS

require 'yaml'
require 'fastercsv'

class EchiFiles
  
  #Load the associated schema definitions of the Avaya ECHI files
  def initialize
    @extended = YAML::load_file(File.expand_path(File.dirname(__FILE__) + "/extended-definition.yml"))
    @standard = YAML::load_file(File.expand_path(File.dirname(__FILE__) + "/standard-definition.yml"))
  end
  
  #Method for parsing the various datatypes from the binary ECHI file
  def dump_binary(filehandle, type, length)
    case type
    when 'int'
      #Process integers, assigning appropriate profile based on length
      #such as long int, short int and tiny int.
      case length
      when 4
        value = filehandle.read(length).unpack("l").first.to_i
      when 2
        value = filehandle.read(length).unpack("s").first.to_i
      when 1
        value = filehandle.read(length).unpack("U").first.to_i
      end
    #Process appropriate intergers into datetime format in the database
    when 'datetime'
      case length
      when 4
        value = filehandle.read(length).unpack("l").first.to_i
        value = Time.at(value)
      end
    #Process strings
    when 'str'
      value = filehandle.read(length).unpack("M").first.to_s.rstrip
    #Process individual bits that are booleans
    when 'bool'
      value = filehandle.read(length).unpack("b8").last.to_s
    #Process that one wierd boolean that is actually an int, instead of a bit
    when 'boolint'
      value = filehandle.read(length).unpack("U").first.to_i
      #Change the values of the field to Y/N for the varchar(1) representation of BOOLEAN
      if value == 1
        value = 'Y'
      else
        value = 'N'
      end
    end
    return value
  end

  #Mehtod that performs the conversions of files
  def convert_binary_file(filehandle, schema, extra_byte)
    
    #Read header information first
    fileversion = dump_binary(filehandle, 'int', 4)
    filenumber = dump_binary(filehandle, 'int', 4)

    bool_cnt = 0
    bytearray = nil
    data = Array.new
    while filehandle.eof == FALSE do
      record = Hash.new
      schema["echi_records"].each do | field |
        #We handle the 'boolean' fields differently, as they are all encoded as bits in a single 8-bit byte
        if field["type"] == 'bool'
          if bool_cnt == 0
            bytearray = dump_binary(filehandle, field["type"], field["length"])
          end
          #Ensure we parse the bytearray and set the appropriate flags
          #We need to make sure the entire array is not nil, in order to do Y/N
          #if Nil we then set all no
          if bytearray != '00000000'
            if bytearray.slice(bool_cnt,1) == '1'
              value = 'Y'
            else
              value = 'N'
            end
          else
            value = 'N'
          end
          record.merge!({ field["name"] => value })
          bool_cnt += 1
          if bool_cnt == 8
            bool_cnt = 0
          end
        else
          #Process 'standard' fields
          value = dump_binary(filehandle, field["type"], field["length"])
          record.merge!({ field["name"] => value })
        end
        
      end

      #Scan past the end of line record if enabled in the configuration file
      #Comment this out if you do not need to read the 'extra byte'
      if extra_byte
        filehandle.read(1)
      end
      data << record
    end
    
    return data
  end

  #Method to create a Ruby hash out of the Avaya ECHI files
  #@filehandle The filehandle
  #@type Whether this is ASCII or Binary data
  #@schema Whether this is the ECHI EXTENDED or STANDARD file format
  def convert_ascii_file(filehandle, schema)

    data = Array.new
    filehandle.each do |line|
      record = Hash.new
      FasterCSV.parse(line) do |row|
        cnt = 0
        row.each do |field|
          if field != nil
            if schema["echi_records"][cnt]["type"] == "bool" || schema["echi_records"][cnt]["type"] == "boolint"
              case field
              when "0"
                record.merge!({ schema["echi_records"][cnt]["name"] => "N" })
              when "1"
                record.merge!({ schema["echi_records"][cnt]["name"] => "Y" })
              when nil
                record.merge!({ schema["echi_records"][cnt]["name"] => "N" })
              else
                record.merge!({ schema["echi_records"][cnt]["name"] => "Y" })
              end
            else
              record.merge!({ schema["echi_records"][cnt]["name"] => field })
            end
            cnt += 1
          end
        end
      end
      data << record
    end
    
    return data
  end
  
  #Pass a filehandle of the file to process that includes
  #@filehandle The filehandle
  #@type Whether this is ASCII or Binary data
  #@format Whether this is the ECHI EXTENDED or STANDARD file format
  #@extra_byte Set to true if you want to read an extra byte at the end of each record
  #This method will return an array of hashes of the resulting data processed
  def process_file(filehandle, type, format, extra_byte)
    
    #Set the appropriate schema format for standard or extended from the Avaya CMS
    case format
    when 'EXTENDED'
      schema = @extended
    when 'STANDARD'
      schema = @standard
    end
    
    #Process based on the filetype passed
    case type
    when 'ASCII'
      return convert_ascii_file(filehandle, schema)
    when 'BINARY'
      return convert_binary_file(filehandle, schema, extra_byte)
    end
    
  end
  
  #Method used to strip special characters
  #@data An Array of Hashes to be processed
  #@fields An array of fields to strip characters from
  #@characters An Array of characters to be stripped
  def strip_special_characters(data, fields, characters)
    stripped_data = Array.new
    data.each do |row|
      fields.each do |field|
        if field == row[0]
          characters.each do |character|
            row[1].gsub!(character.chr, "")
          end
        end
      end
      stripped_data << row
    end
    return stripped_data
  end
  
end