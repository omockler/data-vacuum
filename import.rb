require 'rubygems'
require 'yaml'
require 'digest/md5'
require 'listen'

config = YAML.load_file('./config.yaml')

Dir.chdir(config["source_directory"])
files = Dir['**/*.*']
files.each do |filename|
	file_hash = Digest::MD5.hexdigest(File.read(filename))
	matches = filename.match('([^/]+?)(\.[^.]*$|$)')
	extension = matches[2]
	new_filename = file_hash + extension
	destination = File.join config["vacuum_canister"] + new_filename
	FileUtils.cp filename, destination
end