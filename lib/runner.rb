require 'rubygems'
require 'treetop'
require 'lolcode'

parser = LOLCodeParser.new

code = parser.parse(File.read('test.lolcode') + "\n")
if code
  code.run 
else
  puts "O NOES!"
end