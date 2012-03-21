## PillMopper
# fixing scraped pages

require './constants.rb'

Dir.glob("#{DIRS_HSH['drugs']}/../subpages/**/*.html").each do |fname|

  puts fname
  contents = File.open(fname){|f| f.read}
  
  File.open(fname, 'w'){|o| 
    str = <<HTML 
    <html>
    <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>
    <body>
HTML
    str <<  contents	
    str << "</body></html>"
    
    o.write str
  }

end




