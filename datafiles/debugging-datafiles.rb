## PillMopper
# Storing the datafiles into a proper database
#
# Skill level: 
# Easy
#
# Description:
#
# Check out datafiles for column mismatches and other irregularities
#
require './constants.rb'

$ERRORS = {}
$STATE = {:total_error_count=>0}

def log_error(line, msg='')
#  puts "Error at line #{$STATE[:line_no]}\t#{msg}"
#  puts line.join("\t")
  $STATE[:file_error_count] += 1
  $STATE[:total_error_count] += 1
  
  obj = {
    :line_no=>$STATE[:line_no],
    :line=>line,
    :prev=>$STATE[:prev],
    :msg=>msg
  }
  
  $ERRORS[$STATE[:fname]][:errors] << obj
end

Dir.glob("#{DATAFILES_DIR}/**/ascii/*.TXT").sort_by{|fn| File.basename(fn)}.select{|fn| fn=~/\/DRUG/}.each do |fname|
  puts "\n\n------------------------------\n#{fname}"
  
  file = File.open(fname)
  line = file.readline.chomp
  headers = cols = line.split(/\$/, -1)
  #puts headers.join("\t")
  
  headers_length = headers.length # cache this
  puts "\tNumber of headers:\t#{headers_length}"
  
  $STATE.merge!({:line_no=>1, :file=>file, :fname=>File.basename(fname), :headers=> headers, :file_error_count=>0})
  
  $ERRORS[$STATE[:fname]] = {:headers=> headers, :errors=>[]}
  
  until file.eof?
    $STATE[:line_no] += 1
    $STATE[:prev] = cols
    
    line = file.readline.chomp
    cols = line.split(/\$/, headers_length)
    
    if cols.length != headers_length
      log_error(cols, "Column mismatch; headers: #{headers_length}, line cols: #{cols.length}")
    end
  end

  puts "\n\n*************************\nERROR LISTING:"
  puts $STATE[:file_error_count] > 0 ? "\nErrors found:\t#{$STATE[:file_error_count]}" : 'No errors'
  $ERRORS[$STATE[:fname]][:file_error_count] = $STATE[:file_error_count]
  
  
  file.close
end


puts "\n\n\n\n*************************\nTOTAL ERROR LISTING:"
puts "\nErrors:\t#{$STATE[:total_error_count]}"


File.open("#{DATAFILES_DIR}/errors.log", 'w'){|f| f.write($ERRORS.to_json)}