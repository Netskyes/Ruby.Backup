require "colorize"
require "dropbox_sdk"

sync_path = "sync.txt"
temp_path = "#{File.expand_path File.dirname(__FILE__)}/temp/"

date_time = Time.now
date_time = date_time.strftime("%d.%m.%Y")

output = "#{temp_path}#{date_time}.zip"
command = "7z a -tzip #{output}"

ACCESS_TOKEN = "YOUR ACCESS TOKEN"


def get_lines(path)

	temp_lines = []

	if !File.exist?(path)
		File.new(path, "w")
	else
		File.foreach(path) { |line|
			next if line.length == 0
			line = line.strip
			
			temp_lines.push(line) unless !is_path_valid(line)
		}
	end

	return temp_lines
end

def is_path_valid(path)

	if File.file?(path)
		return File.exist?(path)
	end 

	if File.directory?(path)
		return Dir.exist?(path)
	end

	return false;
end


get_lines(sync_path).each { |path|
	
	if File.directory?(path)
		path << "/" unless path.end_with?("/")
	end
	command << " #{path}"
}

print "Compressing... "
system "#{command} > NUL"

if File.exist?("#{output}")
	puts "OK".green
end


client = DropboxClient.new(ACCESS_TOKEN)
file = File.open("#{output}")

print "Uploading... "
response = client.put_file("/#{date_time}.zip", file)
puts response.inspect

