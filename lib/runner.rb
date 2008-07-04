require 'rubygems'
require 'treetop'
require 'lolcode'

parser = LOLCodeParser.new

Environment = {}

def label(text)
  puts "= " + text + " " + "=" * 50
end

code = parser.parse(File.read('count.lolcode') + "\n")
if code
  label 'TREEZ'
  puts code.inspect
  
  label 'CATBOX'
  value = code.run
  
  label 'INSPEKT'
  puts "output = #{value.inspect}"
  puts code.variables.inspect
else
  puts "O NOES! UR CODE ARE GOING TO BASEMENT!!!"
end
