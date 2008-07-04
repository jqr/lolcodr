require 'rubygems'
require 'treetop'
require 'lolcode'

parser = LOLCodeParser.new

code = parser.parse(File.read('count.lolcode') + "\n")
if code
  code.run 
else
  puts "O NOES! UR C0DZ SUX!!!"
end