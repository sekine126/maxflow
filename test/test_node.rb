require './src/node.rb'
require './test/error.rb'

print "test1:initialize..."
n = Node.new(1)
if n.id != 1
  error
end
puts "pass."

print "test2:inspect..."
n = Node.new(2)
str = "id -> 2"
if n.inspect != str
  error
end
puts "pass."

puts "all test passed!"

