## PillMopper
# Organizing, Overview
#
#
# Skill level: 
# Easy
#
# Description:

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
FILE_DIR = 'data-hold/datafiles/raw'

filenames = {}

Dir.glob("#{FILE_DIR}/**/SIZE*.TXT").each do |fname|  
  File.open(fname).readlines.each do |line|
    if vals = line.match(/^(\w+)\.TXT\s+([\d,]+)\s+([\d,]+)/)
      o = {'fname'=>vals[1], 'records'=>vals[2], 'rows'=>vals[3]}
      fstem = o['fname'][0..3]
      (filenames[fstem] ||= []) << o
    end
  end
end

filenames.each_pair do |fstem, arr|
  arr.sort_by{|v| v['fname']}.each do |f|
    puts [f['fname'], f['records'], f['rows']].join("\t")
  end
end