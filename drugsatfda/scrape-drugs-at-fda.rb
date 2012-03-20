## PillMopper
# Fetching Drugs@FDA
#
#
# Skill level: 
# Easy
#
# Description:
# We need a canonical list of drug names, including generic equivalents
# The Drugs@FDA is a good place to start
#
# This is a pretty standard scraping operation, though there are nested pages
#  http://www.accessdata.fda.gov/scripts/cder/drugsatfda/index.cfm?fuseaction=Search.SearchResults_Browse&DrugInitial=S&StartRow=1&StepSize=5000
#
# We'll just save and store the pages for now, parse them in a different script

require './constants.rb'

BASE_URL = 'http://www.accessdata.fda.gov/scripts/cder/drugsatfda/'
BASE_ENDPOINT = 'index.cfm?'
ATTR_HSH = {
  'fuseaction' => 'Search.SearchResults_Browse',
  'StartRow' => 1,
  'StepSize' => 5000,
  'DrugInitial' => nil  # the only parameter to worry about
}

agent = Mechanize.new()


(('A'..'Z').to_a << '0-9').each do |drug_initial|
  # open index page for the letter
  index_url = BASE_URL + BASE_ENDPOINT + ATTR_HSH.merge({'DrugInitial'=>drug_initial}).map{|a| "#{a[0]}=#{a[1]}"}.join('&')
  puts "\n\n#{index_url}"   
  index_page = agent.get(index_url).parser
    
  # save it to the hard drive
  open(DIRS_HSH['index'] + "/#{drug_initial}.html" , 'w'){|_o| _o.write(index_page.to_html)}
  
  # parse the page for drug links
  drug_links = index_page.css('td.product_table li a')
  
  drug_links.each do |drug_link|
    drug_url = BASE_URL + drug_link['href']
    drug_url_name = drug_url.match(/&DrugName=([^&]+)/)[1]
    puts drug_url_name
    
    # open the drug page
    drug_page = agent.get(drug_url).parser  
    
    # save the page
    open(DIRS_HSH['drugs'] + "/#{drug_url_name}.html", 'w'){|_o| _o.write(drug_page.css('#content').to_html)}
    
    # parse the page
    inner_links = drug_page.css('tr ul li a[href*="fuseaction"]')
    
    next if inner_links.length < 1
    
    local_inner_dir = File.join(DIRS_HSH['subpages'], drug_url_name)
    FileUtils.makedirs(local_inner_dir)
    
    inner_links.each do |inner_link|
      inner_url = BASE_URL + inner_link['href']
      inner_url_base = inner_link['href'].match(/Search\.(\w+)/)[1]
      puts "\t#{inner_url}"
      
      inner_page = agent.get(inner_url).parser
      open(local_inner_dir + "/#{inner_url_base}.html", 'w'){|_o| _o.write(inner_page.css('#content').to_html)}
    end
  end  

end



