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


## TODO:
# - Redo table imports...EVERY ROW is delimited by $ ???
# - Add indexes on ROLE_COD, ISR, DRUG_SEQ
#

require './constants.rb'
require 'mysql'

START_LINE = 'C. DATA ELEMENT DESCRIPTIONS'
END_LINE = 'D. DATA ELEMENT CONTENTS AND MAXIMUM LENGTHS'
SKIP_LINES = [
  /^\s*$/,
  /^NAME\s+DESCRIPTION/,
  /^-{2,}/  
]


lines = File.open(README_FILE).readlines[40..-1] # skip Table of Contents
lines = lines[ lines.index{|x| x.index START_LINE}...lines.index{|x| x.index END_LINE} ]


table_info = []
obj, field_hsh = nil
while line = lines.shift
  
  if tbl_info = line.match(/\d\) +(.+?) \((\w{4})\w{4}\.TXT\)/)
    #create new object
    
    
    desc, filestem = tbl_info[1..2]
    obj = {'description'=>desc, 'file_stem'=>filestem, 'fields'=>[]}
    table_info << obj 
        
    puts "\n\t#{desc}"
  elsif SKIP_LINES.index{|regex| line =~ regex}
    # skip  
  else
    
    # inside a data field line
    if line[0..1] =~ /[A-Z][A-Z_]/
      # beginning of a datafield
      
      field_name, field_desc = line.match(/^([A-Z_]+)\s+(.+)/)[1..2]
      field_hsh = {'name'=>field_name, 'description'=>field_desc}
      obj['fields'] << field_hsh 
      
      
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


### Set up MySQL
### set up fda_data database first
mdb = Mysql::new("localhost", "root", "", "fda_data")



puts "results\n\n\n\n"

table_info.each do |table|
  tbl_name = table['file_stem']
  puts "\n\n-----------------\n#{tbl_name}"
  
  puts table['description']
  
  mdb.query("DROP TABLE IF EXISTS `#{tbl_name}`; ")
  mysql_q = "CREATE TABLE `#{tbl_name}`(
    #{table['fields'].map{|fd| "`#{fd['name']}` VARCHAR(255)"}.join(",\n\t") },
    `year` INT(4), `quarter` INT(1) ); "
  
  puts mysql_q
  mdb.query(mysql_q)

  # now grab each file of that stem and input it into database
  puts "Inserting files into database...\n"
  
  Dir.glob("#{DATAFILES_DIR}/**/#{tbl_name}*.TXT").each do |fname|
    puts "Loading #{fname}"
    file = File.open(fname)
    year,quarter = File.basename(fname).match(/(\d{2})Q(\d{1})/)[1..2]
    year = "20#{year}" # obv., this won't work in 2100+ A.D.
    
    # get headers
    headers = file.readline.chomp.split("$")
    h_lth = headers.length
#    1000.times.each do |line_num|
     line_num = 1
     until file.eof?
      cols = file.readline.chomp.split("$", h_lth); 
      line_num += 1
#      puts headers.length
#      puts cols.length
      
      q = "INSERT INTO #{tbl_name}(
        #{headers.map{|h| "`#{h}`"}.join(',')}, year, quarter
      )
      VALUES(
        #{cols.map{|c| "\"#{mdb.escape_string(c)}\""}.join(',')}, #{year}, #{quarter}      
      )
      "
     
     # puts q
      begin
        mdb.query(q)
      rescue
        puts "Problem with line #{line_num}"
        puts cols.join("\t")
      end
      
    end
    
  end
  
    
#  table['fields'].each do |field|
#    puts [field['name'], field['description'].gsub(/\s+/, ' ') ].join("\t>>\t")
 
     
    
#    if codes = field['codes']
#       codes.each do |code|
#         puts "\t#{code.join('=>')}"
#       end
#    end 
    
#  end
  
end

# Program exited with code #0 after 7213.98 seconds.

