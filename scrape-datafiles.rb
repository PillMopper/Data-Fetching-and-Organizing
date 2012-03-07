## PillMopper
# Scraping and Fetching
#
#
# Skill level: 
# Easy
#
# Description:
# This file retrieves each ASCII zip file from the FDA AERS download site and downloads it to
# your local filesystem, in this format:
# year/quarter/_files.*
#
# It also automatically unzips each zip file
#
# Just a trivial exercise in web scraping that saves us about 15 - 30 minutes of manual labor
#
# I've left the code verbose, this could be done in about 10 lines

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

BASE_FDA_URL = 'http://www.fda.gov'
URLS = {
  'current' => 'http://www.fda.gov/Drugs/GuidanceComplianceRegulatoryInformation/Surveillance/AdverseDrugEffects/ucm082193.htm',
  'older' => 'http://www.fda.gov/Drugs/GuidanceComplianceRegulatoryInformation/Surveillance/AdverseDrugEffects/ucm083765.htm'
}

FILE_DIR = 'data-hold/datafiles/raw'
FileUtils.makedirs(FILE_DIR) 

URLS.each_pair do |k, url|
  
  puts url
  
  page = Nokogiri::HTML(open(url))
  
  page.css('blockquote').each do |bq| # why these are blockquotes, who knows...
    
    # Only want the ASCII versions
    bq.css('ul li a').select{|a| a.text =~ /ASCII/ }.each do |link|      
      
      # for some reason, the actual zip file is named differently from the text link
      label = link.text
      href =  File.join(BASE_FDA_URL, link['href'])

      year, quarter = File.basename(label).match(/(\d{4})(q\d)/)[1..2]
      puts [label, year,quarter ].join("\t")
      
      # download the file
      local_filename = File.join(FILE_DIR, label)
      puts "\nDownloading #{href} to #{local_filename}"
      
      download_attempts = 3
      begin
        File.open(local_filename, 'wb'){|f| f.write(open(href, 'rb').read) };
      rescue Exception => e
        puts "Had a downloading error"
        download_attempts -= 1
        if download_attempts > 0
          puts "Attempting #{download_attempts} more times"
          sleep 6
          retry
        else
          puts "\nMoving on...Could not retrieve the file at: #{href}"
        end
      else
        
        local_folder = File.join(FILE_DIR, year,quarter)
        FileUtils.makedirs(local_folder)
      
        puts "\nUnzipping #{local_filename} into #{local_folder}"
        `unzip #{local_filename} -d #{local_folder}`
      
      end
      
    end
  end
end


# Program exited with code #0 after 275.41 seconds.