#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'socket'
require 'json'
$KCODE = 'u'

HOST = "192.168.1.37"
PORT = 20000

s = TCPSocket.open(HOST, PORT)
s.puts "MESSAGE shokaishokai hellohellohello"

msgs = Array.new
loop do
  Thread.start(s){|s|
    loop do
      begin
        res = s.gets
        exit unless res
        p JSON.parse res
      rescue => e
        STDERR.puts e
      end
      sleep 0.1
    end
  }
  Thread.start(s){|s|
    loop do
      s.puts gets
    end
  }
end
