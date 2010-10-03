#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# キーワードに反応する単純なbot

require 'rubygems'
require 'socket'
require 'json'
require 'yaml'
require 'mongo'
$KCODE = 'u'

begin
  conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')
rescue => e
  STDERR.puts "config.yaml laod error"
  STDERR.puts e
  exit 1
end

begin
  m = Mongo::Connection.new(conf['mongo_host'], conf['mongo_port'])
  db = m.db(conf['mongo_dbname'])
rescue => e
  STDERR.puts "mongo db connection error"
  STDERR.puts e
  exit 1
end

s = TCPSocket.open(conf['host'], conf['port'])
s.puts "MESSAGE #{conf['me']} skype_chat_store_mongo start"

msgs = Array.new
loop do
  Thread.start(s){|s|
    loop do
      begin
        res = s.gets
        exit unless res
        p res = JSON.parse(res)
        if res['type'] != 'error' and res['type'] != 'api_response'
          res['time'] = Time.now.to_i
          db['chat'].insert(res)
        end
      rescue => e
        STDERR.puts e
      end
      sleep 0.1
    end
  }
end
