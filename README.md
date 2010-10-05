skype socket gateway
====================
Skype API <---> TCP Socket

* call Skype API via socket.
* response format is json.
* forwards all chat messages.

Dependencies
============
* Ruby4Skype (rubygem)
* json (rubygem)
* eventmachine (rubygem)
* Skype

Ruby4Skype works on Windows, Mac and Linux.
I'm testing on Windows XP + ActiveRuby 1.8.7.

    % gem install Ruby4Skype 
    % gem install json
    % gem install eventmachine


Run
===

Run Skype, then

    % ruby skype-gateway.rb


Use
===

    % telnet localhost 20000
    % > MESSAGE shokaishokai hellohello!!


Make skype bot
==============
see "samples" directory.

    ## connect
    % require 'socket'
    % s = TCPSocket.open("192.168.1.100", 20000)

    ## use Skype API
    ## call
    % s.puts "CALL shokaishokai"
    # send message
    % s.puts "MESSAGE shokaishokai hellowork!!"

    ## receive
    % require 'rubygems'
    % require 'json'
    % p JSON.parse s.gets
 