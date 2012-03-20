## PillMopper
# Parsing Drugs@FDA for list of names
#
#
# Skill level: 
# Easy
#
# Description:
# We need a canonical list of drug names, including generic equivalents
# The Drugs@FDA is a good place to start
#
#
# Fields:
# Drug name
# Company
# Active Ingredient
# Approval date
# FDA Application Number
# Has generics?


require './constants.rb'

Dir.glob("#{DIRS_HSH['drugs']}/*.html").each do |fname|
  drug_name = CGI.unescape(File.basename(fname, '.html'))
  base_drug_name = drug_name.split(' ')[0]
  puts [base_drug_name, drug_name].join("\t")
end




