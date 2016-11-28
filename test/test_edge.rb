require './src/maxflow_network/edge.rb'
require './test/error.rb'

print "test1:initialize..."
e = Edge.new(1,2)
if e.from != 1
  error
end
if e.to != 2
  error
end
if e.flow != nil
  error
end
if e.capacity != nil
  error
end
e = Edge.new(1,2,3)
if e.from != 1
  error
end
if e.to != 2
  error
end
if e.flow != 3
  error
end
if e.capacity != nil
  error
end
e = Edge.new(1,2,3,4)
if e.from != 1
  error
end
if e.to != 2
  error
end
if e.flow != 3
  error
end
if e.capacity != 4
  error
end
puts "pass."

print "test2:inspect..."
e = Edge.new(1,2,3,4)
str = "1 -> 2 : 3 / 4"
if str != e.inspect
  error
end
puts "pass."

puts "all test passed!"

