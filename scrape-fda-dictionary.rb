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


# Program exited with code #0 after 275.41 seconds.