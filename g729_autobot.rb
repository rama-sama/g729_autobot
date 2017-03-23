#!/usr/bin/env ruby

require 'optparse'
require 'logger'
require 'fileutils'

logger = Logger.new(STDOUT)

# Parse config file for configuration options
config = File.readlines('config')
config_opts_and_values = {}
config.each do |line|
  key = line.strip.split('=')[0]
  value = line.strip.split('=')[1]
  config_opts_and_values[key] = value
end

# Parse command line options
@opts = {source:nil, dest:nil, file:nil}
OptionParser.new do |opts|
  opts.banner = 'Usage: ./g729_autobot.rb -f <pcap path> -s <source udp port> -d <dest udp port>'
  opts.on('-s', '--source PORT', String, 'UDP Source Port') { |o| @opts[:source] = o }
  opts.on('-d', '--dest PORT', String, 'UDP Dest Port') { |o| @opts[:dest] = o }
  opts.on('-f', '--file NAME', String, 'Path to pcap with two way RTP stream') { |o| @opts[:file] = o }
end.parse!
abort "Usage: ./g729_autobot.rb -f <pcap path> -s <source udp port> -d <dest udp port>
Use --help for more info" if @opts.any? { |k,v| v.nil? }

# Creates uni-directional filter expressions for tshark
def filter(direction)
  case direction
  when 'forward'
    return "(udp.srcport == #{@opts[:source]} && udp.dstport == #{@opts[:dest]})"
  when 'reverse'
    return "(udp.srcport == #{@opts[:dest]} && udp.dstport == #{@opts[:source]})"
  end
end

# Set up file names and paths
pcap_path = File.absolute_path(@opts[:file])
pcap_name = File.basename(@opts[:file], ".*")

anchor_dir = config_opts_and_values['anchor_dir']
codecpro_dir = config_opts_and_values['codecpro_dir']

pcap_dir = "#{anchor_dir}/filtered_pcaps"
audio_dir = "#{anchor_dir}/audio_files"

[pcap_dir, audio_dir].each { |d| Dir.mkdir(d) unless Dir.exist?(d) }
pcap_forward = "#{pcap_dir}/#{pcap_name}_#{@opts[:source]}_#{@opts[:dest]}_forward"
pcap_reverse = "#{pcap_dir}/#{pcap_name}_#{@opts[:source]}_#{@opts[:dest]}_reverse"

# Parse pcap for RTP streams
logger.info("Parsing #{pcap_name} for RTP streams")
system("tshark -r '#{pcap_path}' -Y '#{filter('forward')}' -w '#{pcap_forward}'")
system("tshark -r '#{pcap_path}' -Y '#{filter('reverse')}' -w '#{pcap_reverse}'")

# Run external scripts to convert RTP to a .au file
[pcap_forward, pcap_reverse].each do |pcap|
  basename = File.basename(pcap, ".*")

  logger.info("Extracting RTP stream and dumping raw output")
  system("perl lib/rtp_dump.pl '#{pcap}' '#{audio_dir}/#{basename}.raw'")

  logger.info("Converting raw to PCM")
  system("wine #{codecpro_dir}/cp_g729_decoder.exe '#{audio_dir}/#{basename}.raw' '#{audio_dir}/#{basename}.pcm'")

  logger.info("Converting PCM to Audio file format")
  system("perl lib/pcm2au.pl '#{audio_dir}/#{basename}.pcm' '#{audio_dir}/#{File.basename(pcap)}.au'")

  logger.info("Deleting raw and PCM files")
  ["#{audio_dir}/#{basename}.raw", "#{audio_dir}/#{basename}.pcm"].each do |file|
    File.delete(file)
  end
end
