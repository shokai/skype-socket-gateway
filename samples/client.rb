#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'socket'
require 'json'
require 'eventmachine'
$KCODE = 'u'

HOST = "192.168.1.37"
PORT = 20000

begin
  s = TCPSocket.open(HOST, PORT)
  s.puts "MESSAGE shokaishokai sample/client.rb start"
rescue => e
  STDERR.puts e
  exit 1
end

EventMachine::run do

  EventMachine::defer do
    loop do
      res = s.gets
      exit unless res
      res = JSON.parse res rescue next
      p res
    end
  end

  EventMachine::defer do
    loop do
      s.puts gets
    end
  end

end

