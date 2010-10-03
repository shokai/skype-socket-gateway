require "rubygems"
require "skype"

puts "start"
app_name = "test_app"
Skype.init app_name
Skype.attach_wait

s = Skype::Application.new(app_name)

p chats = s.invoke("SEARCH ACTIVECHATS")
chats = chats.split(/ /)
chats.shift
p chats
