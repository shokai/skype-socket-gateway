#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# キーワードに反応する単純なbot

require 'rubygems'
require 'socket'
require 'json'
require 'eventmachine'
$KCODE = 'u'

HOST = "192.168.1.37"
PORT = 20000

s = TCPSocket.open(HOST, PORT)
s.puts "MESSAGE shokaishokai ざんまいbot start"

EventMachine::run do
  loop do
    begin
      res = s.gets
      exit unless res
      p res = JSON.parse(res)
      if res['type'] == 'chat_message' 
        if res['body'] =~ /ざんまい/ # キーワードに反応
          s.puts "CHATMESSAGE #{res['chat']} ざんまい行きたい！"
        elsif res['body'] =~ /かず(すけ|助)/
          s.puts "CHATMESSAGE #{res['chat']} かずにゃんぺろぺろ"
        end
      end
    rescue => e
      STDERR.puts e
    end
    sleep 0.1
  end
end
