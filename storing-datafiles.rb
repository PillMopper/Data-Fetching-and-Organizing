## PillMopper
# Storing the datafiles into a proper database
#
# Skill level: 
# Easy
#
# Description:
# Parse the Asc_nts readme file to get:
# * Tables (name and description)
# * Field names and descriptions
# * Possible code values for a particular field
#
#
# We then use this data to build a database
#
# This looks like more work than it's worth, especially with only 6 tables
# But it's more fun than tediously entering this information



require 'rubygems'
require 'fileutils'

START_LINE = 'C. DATA ELEMENT DESCRIPTIONS'
END_LINE = 'D. DATA ELEMENT CONTENTS AND MAXIMUM LENGTHS'
SKIP_LINES = [
  /^\s*$/,
  /^NAME\s+DESCRIPTION/,
  /^-{2,}/  
]

README_FILE = 'data-hold/datafiles/Asc_nts.txt'
lines = File.open(README_FILE).readlines[40..-1] # skip Table of Contents
lines = lines[ lines.index{|x| x.index START_LINE}...lines.index{|x| x.index END_LINE} ]


table_info = []
obj, field_hsh = nil
while line = lines.shift
  
  if tbl_info = line.match(/\d\) +(.+?) \((\w{4})\w{4}\.TXT\)/)
    #create new object
    
    table_info << obj if obj
    
    desc, filestem = tbl_info[1..2]
    obj = {'description'=>desc, 'file_stem'=>filestem, 'fields'=>[]}
        
    puts "\n\t#{desc}"
  elsif SKIP_LINES.index{|regex| line =~ regex}
    # skip  
  else
    
    # inside a data field line
    if line[0..1] =~ /[A-Z][A-Z_]/
      # beginning of a datafield
      obj['fields'] << field_hsh if field_hsh
      
      field_name, field_desc = line.match(/^([A-Z_]+)\s+(.+)/)[1..2]
      field_hsh = {'name'=>field_name, 'description'=>field_desc}
    else
      # description continues
      if line =~ /----\s+-+/
        # there is a list of codes here
        field_hsh['codes'] = []

        # attempting mini loop
        while (code_line = lines.shift) && code_line =~ /\w/
          field_hsh['codes'] << code_line.strip.split(/\s{2,}/)
        end
        # end mini loop for codes
        
      else    
        field_hsh['description'] << line if field_hsh
      end  # end of field description

    end # end of data field listing
    
  end # end of # if line...
  
end # end of while


puts "results\n\n\n\n"

table_info.each do |table|
  puts table['name']
  puts table['description']
  
  table['fields'].each do |field|
    puts [field['name'], field['description'].gsub(/\s+/, ' ') ].join("\t>>\t")
    
    if codes = field['codes']
       codes.each do |code|
         puts "\t#{code.join('=>')}"
       end
    end 
    
  end
  
end
