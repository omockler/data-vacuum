require 'rubygems'
require 'yaml'
require 'digest/md5'
require 'listen'

config = YAML.load_file('./config.yaml')
canister = Dir.open(config["vacuum_canister"])

# Load all hashes from our backup folder
hashes = []
canister.each do |filename|
	next if File.directory? filename
	matches = filename.match('([^/]+?)(\.[^.]*$|$)')
	hashes << matches[1]
end

Listen.to!(config["source_directory"], :relative_paths => false) do |modified, added|
	paths = modified + added
	paths.each do |filename|
		file_hash = Digest::MD5.hexdigest(File.read(filename))
		result = filename.match('([^/]+?)(\.[^.]*$|$)')
		extension = result[2]
		new_filename = file_hash + extension
		next if hashes.detect {|h| h == file_hash}
		destination_path = File.join canister, new_filename
		FileUtils.cp filename, destination_path
		hashes << file_hash
	end
end