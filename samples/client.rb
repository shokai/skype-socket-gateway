#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'socket'
require 'json'
require 'eventmachine'
$KCODE = 'u'

HOST = "192.168.1.37"
PORT = 20000

s = TCPSocket.open(HOST, PORT)
s.puts "MESSAGE shokaishokai sample/client.rb start"

EventMachine::run do
  loop do
    res = s.gets
    exit unless res
    res = JSON.parse res rescue next
    p res
    sleep 0.1
  end
end

EventMachine::run do
  loop do
    s.puts gets
  end
end
