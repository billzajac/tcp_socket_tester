tcp_socket_tester
=================

A super simply ruby tcp socket tester

## Usage
    USAGE: ./test_socket.rb HOST PORT [TIMEOUT]
           TIMEOUT is in seconds (can be decimal) - default: 0.5

## Example usage
    $ ./test_socket.rb 127.0.0.1 22
    connected

    $ ./test_socket.rb 127.0.0.1 23
    connection refused - nothing listening at: 127.0.0.1:23

    $ ./test_socket.rb foo 22
    Error with host or port: foo:22 -- (getaddrinfo: nodename nor servname provided, or not known)

    $ ./test_socket.rb 10.190.58.10 3456
    timed out - likely firewall blocking: 10.190.58.10:3456

