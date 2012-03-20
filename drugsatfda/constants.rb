## PillMopper
# Fetching Drugs@FDA
# Helper file

require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'fileutils'
require 'cgi'

module Constants
  DATA_DIR = 'data-hold'
  DIRS_HSH = {
    'index' => "#{DATA_DIR}/indexes",
    'drugs' => "#{DATA_DIR}/drugs",
    'subpages' => "#{DATA_DIR}/subpages"
  }
end

include Constants



