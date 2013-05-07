#!/usr/bin/env ruby

require 'socket'

@default_timeout = 0.5
host = ARGV[0]
port = ARGV[1]
timeout = ARGV[2] ? ARGV[2].to_f : @default_timeout

def usage(message)
  puts "USAGE: #{$0} HOST PORT [TIMEOUT]"
  puts "       TIMEOUT is in seconds (can be decimal) - default: #{@default_timeout}"
  puts
  puts message
  puts
  exit(1)
end

#------------------------------------
# Validate the args
#------------------------------------
if port.nil?
  usage
end
port = port.to_i

if port <= 0 or port > 65535
  usage("ERROR: port is not reasonable: #{port}")
end

#------------------------------------
# Catch DNS errors or typos here
#------------------------------------
begin
  addr = Socket.pack_sockaddr_in(port, host)
  sock = Socket.new(:AF_INET, :SOCK_STREAM, 0)
rescue Exception => e
   puts "Error with host or port: #{host}:#{port} -- (#{e})"
   exit 1
end

#------------------------------------
# First we will check to see if the socket is closed
#------------------------------------
begin
  sock.connect_nonblock(addr)
rescue IO::WaitWritable
  begin 
    # This is a way to achieve a timeout for the socket connection
    # http://www.ruby-forum.com/topic/2225837
    if IO.select(nil, [sock], nil, timeout)
      #------------------------------------
      # If we haven't timed out, then lets try to connect again
      #------------------------------------
      begin
        sock.connect_nonblock(addr)
        puts "connected"
        exit
      rescue Errno::ECONNREFUSED
        # Note that we don't just check for refused in the outer block
        # because it could force us to wait a long time if it is 
        # actually going to time out instead
        puts "connection refused - nothing listening at: #{host}:#{port}"
        exit 1
      rescue Errno::EISCONN # check for connection failure
      end
    else
      sock.close
      puts "timed out - likely firewall blocking: #{host}:#{port}"
      exit 1
    end
    puts connect_status = "connected"
    exit
  end
end
