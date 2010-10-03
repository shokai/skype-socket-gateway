#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# skype chatをmongo dbに保存する

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

begin
  s = TCPSocket.open(conf['host'], conf['port'])
  s.puts "MESSAGE #{conf['me']} skype_chat_store_mongo start"
rescue => e
  STDERR.puts e
  exit 1
end

loop do
  res = s.gets
  exit unless res
  res = JSON.parse(res) rescue next
  if res['type'] != 'error' and res['type'] != 'api_response'
    res['time'] = Time.now.to_i
    db['chat'].insert(res)
    p res
    if res['body'] =~ /mongo.*count/
      count = db['chat'].count
      s.puts "CHATMESSAGE #{res['chat']} #{count}"
    end
  end
  sleep 0.1
end
