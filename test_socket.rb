#!/usr/bin/env ruby

require 'socket'

host = ARGV[0]
port = ARGV[1]
timeout = ARGV[2] ? ARGV[2] : 0.5

if port.nil?
  puts "USAGE: #{$0} HOST PORT [TIMEOUT]"
  exit(1)
end

addr = Socket.pack_sockaddr_in(port, host)
sock = Socket.new(:AF_INET, :SOCK_STREAM, 0)

# First we will check to see if the socket is closed
connect_status = ""
begin
  sock.connect_nonblock(addr)
rescue IO::WaitWritable
#rescue Errno::EINPROGRESS
  begin 
    # This is a way to achieve a timeout for the socket connection
    # http://www.ruby-forum.com/topic/2225837
    if IO.select(nil, [sock], nil, timeout)
      # If we haven't timed out, then lets try to connect again
      begin
        sock.connect_nonblock(addr)
        connect_status = "connected"
      rescue Errno::ECONNREFUSED
        # Note that we don't just check for refused in the outer block
        # because it could force us to wait a long time if it is 
        # actually going to time out instead
        connect_status = "connection refused"
      rescue Errno::EISCONN # check for connection failure
      end
    else
      sock.close
      connect_status = "timed out"
    end
  end
end

puts connect_status
