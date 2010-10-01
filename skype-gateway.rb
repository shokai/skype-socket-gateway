require "rubygems"
require "skype"
require "socket"
require "json"

APP_NAME = "skype socket gateway"
PORT = 20000

Skype.init APP_NAME
Skype.start_messageloop
Skype.attach_wait

skype = Skype::Application.new(APP_NAME)

sock = TCPServer.open PORT
p sock.addr

chat_msgs = Array.new

Skype::ChatMessage.set_notify :status, 'RECEIVED' do |msg|
  begin
    p data = {
      :type => 'chat_message',
      :chat => msg.get_chat.to_s,
      :from => msg.get_from.to_s,
      :body => msg.get_body.to_s
    }
    chat_msgs.push data
  rescue => e
    STDERR.puts e
  end
end

loop do
  s = sock.accept

  # skype chat -> socket
  Thread.start(s){|s|
    loop do
      begin
        s.puts "\n"+chat_msgs.shift.to_json if chat_msgs.size > 0
      rescue => e
        STDERR.puts e
      end
      sleep 1
    end
  }

  # socket -> skype
  Thread.start(s){|s|
    loop do
        cmd = s.gets
        puts "recv => #{cmd}"
      begin
        p res = {
          :type => 'api_response',
          :body => skype.invoke(cmd).to_s
        }
      rescue => e
        res = {
          :type => 'error',
          :body => 'skype api invoke error'
        }
        STDERR.puts e
      end
      s.puts "\n"+res.to_json
      sleep 1
    end
  }
end
