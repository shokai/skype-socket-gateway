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
    chat_msgs << data
  rescue => e
    STDERR.puts e
  end
end

clients = Array.new

# forward all skype chats -> socket
Thread.new{
  loop do
    if chat_msgs.size > 0
      msg = "\n"+chat_msgs.shift.to_json 
      clients.each{|c|
        begin
          c.puts msg
        rescue => e
          STDERR.puts e
        end
      }
    end
    sleep 1
  end
}

# check clients connection
Thread.new{
  loop do
    msg = ''
    errors = Array.new
    clients.each{|c|
      begin
        c.puts msg
      rescue => e
        STDERR.puts e
        errors << c
      end
    }
    errors.each{|c|
      clients.delete(c)
      c.close
    }
    sleep 15
  end
}


loop do
  s = sock.accept
  clients << s
  puts clients.size

  # socket -> invoke Skype API
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
      begin
        s.puts "\n"+res.to_json
      rescue => e
        STDERR.puts e
        c.close
        break
      end
      sleep 1
    end
  }
end
