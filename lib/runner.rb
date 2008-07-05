require 'rubygems'
require 'treetop'
require 'lolcode'

parser = LOLCodeParser.new

Environment = {}

def label(text)
  puts "\n= " + text + " " + "=" * 50
end

code = parser.parse(File.read('count.lolcode') + "\n")
if code
  label 'TREEZ'
  puts code.inspect
  
  label 'CATBOX'
  value, env = code.run
  
  label 'INSPEKT'
  puts "returns = #{value.inspect}"
  puts env.inspect
else
  puts "O NOES! UR CODE ARE GOING TO BASEMENT!!!"
end
