#!/usr/bin/env ruby

require "net/http"
require "json"
require "uri"
require "tmpdir"

client_id = "6a795e1aa3ce98a41c66432a61633e4e";

# Get the URL
url = ARGV[0]
puts "Retrieving #{url}"

# Get the stream URL, ask the soundcloud server
resolve_url = "http://api.soundcloud.com/resolve.json?url="
resolve_request_url = "#{resolve_url}#{url}&client_id=#{client_id}"

puts "Resolving..."

resolve_request_url = URI.parse(resolve_request_url)

response = JSON.parse Net::HTTP.get_response(resolve_request_url).body

# Get url location for actual API resuest
resolved_url = response["location"]

puts "Resolved #{resolved_url}"

# Request the actual info
track_info = Net::HTTP.get_response( URI.parse(resolved_url) ).body
track_info = JSON.parse track_info

# Get the track stream URL
track_stream_url = "#{track_info["stream_url"]}?client_id=#{client_id}"

puts "Found stream #{track_stream_url}"

# Download song to temporary folder, let the Ruby core handle it
temp_dir = "#{Dir.tmpdir}"
filename = "#{temp_dir}/#{Time.now.to_i}.mp3"

puts "Saving to #{filename}"

system("curl -L #{track_stream_url} > #{filename}")

puts "Got the file."

puts "Attempting to play the file... (#{filename})"

exec("afplay #{filename}")
