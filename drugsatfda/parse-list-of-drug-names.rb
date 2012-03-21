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
require 'set'

REGEX_SPLITTERS = /\bFOR\b|W\/|\bWITH\b|\bAND\b|\bIN\b|;|,|\(.+?\)|'.+?'|".+?"/

token_set = Set.new

Dir.glob("#{DIRS_HSH['drugs']}/*.html").each do |fname|
  
  drug_name = CGI.unescape(File.basename(fname, '.html')).upcase
  tokens = drug_name.split(REGEX_SPLITTERS).reject{|t| t.length < 4 || t =~ /^(?:\d+)/} 
  tokens << drug_name.match(/^\d*\-*[A-Z]{3,}/).to_s
  token_set.merge(tokens)
  

end

token_array =  token_set.to_a.map{|t| t.strip}.sort

puts token_array.join("\n")
puts token_array.length


