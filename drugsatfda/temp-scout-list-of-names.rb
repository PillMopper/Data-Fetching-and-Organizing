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

REGEX_SPLITTERS = /FOR|W\/|\bWITH\b|\bAND\b|\bIN\b|;|,/
 ughs = Set.new

Dir.glob("#{DIRS_HSH['drugs']}/*.html").each do |fname|
  drug_name = CGI.unescape(File.basename(fname, '.html'))
  ughs.merge drug_name.scan(/\b.{1,3}\b/)
end

puts ughs.to_a.join("\n")



