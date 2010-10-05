require 'rubygems'
require 'skype'
require 'socket'
require 'eventmachine'
require 'json'

APP_NAME = "skype socket gateway"
PORT = 20000

Skype.init APP_NAME
Skype.start_messageloop
Skype.attach_wait

skype = Skype::Application.new(APP_NAME)

sock = TCPServer.open PORT
p sock.addr

clients = Array.new
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

# forward all skype chats -> socket
EventMachine::run do
  EventMachine::defer do
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
    end
  end

  # check clients connection
  EventMachine::defer do
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
  end

  
  EventMachine::defer do
    loop do
      s = sock.accept
      clients << s
      puts "--- new client : #{clients.size}"
      
      # socket -> invoke Skype API
      EventMachine::defer do
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
        end
      end
    end
  end
  
end



