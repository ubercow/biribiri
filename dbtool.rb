#!/usr/bin/env ruby
# encoding: UTF-8

APP_ROOT = File.dirname(__FILE__)
ENV["BUNDLE_GEMFILE"] = APP_ROOT + "/Gemfile"
$:.unshift APP_ROOT + "/lib"

require "bundler"
Bundler.setup(:default)
require "logger"
require "active_record"
require "biribiri"
require "commander/import"
require "terminal-table"
include Biribiri

Logger.setup(STDOUT)

opts = Options.new
opts.load_config(File.expand_path("../config.yaml", __FILE__))
options = opts.options

# Get logging online
Logger.log.level = options[:logging][:level]
Logger.log.debug "DEBUGGING ONLINE!"

Logger.log.debug "Connecting to Database"
# Connect to database
ActiveRecord::Base.establish_connection(options[:database])
ActiveRecord::Base.logger = Logger.log

program :name, "dbtool"
program :description, "Database maintance tool for those who are lazy"
program :version, "0.1.0"

command :list do |c|
	c.syntax = "dbtool.rb list"
	c.description = "Lists torrents and backlogs"
	c.action do |args, options|
		backlog_rows = Biribiri::Backlog.all.map do |row|
			[row.id, row.path, row.expire, row.added, row.runs]
		end
		puts Terminal::Table.new(
			:title => "Backlog", 
			:headings => ["ID", "Path", "Added", "Expires", "Runs"], 
			:rows => backlog_rows)

		puts "\n\n"
		
		torrent_rows = Biribiri::Torrents.all.map do |row|
			[row.id, row.hash_string, row.name, row.copied?]
		end

		puts Terminal::Table.new( 
			:title => "Torrents", 
			:headings => ["ID", "Hash", "Name", "Copied?"],
			:rows => torrent_rows)
	end
end