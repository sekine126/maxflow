require './src/network.rb'
require './test/error.rb'

print "test1:connect..."
n = Network.new
e = n.connect(1,2)
if e.from != 1 && e.from != n.edges[0].from
  error
end
if e.to != 2 && e.to != n.edges[0].to
  error
end
if e.flow != nil && e.flow != n.edges[0].flow
  error
end
if e.capacity != nil && e.capacity != n.edges[0].capacity
  error
end
e = n.connect(2,1,3,4)
if e.from != 2 && e.from != n.edges[1].from
  error
end
if e.to != 1 && e.to != n.edges[1].to
  error
end
if e.flow != 3 && e.flow != n.edges[1].flow
  error
end
if e.capacity != 4 && e.capacity != n.edges[1].capacity
  error
end
if n.edges.size != 2
  error "size"
end
puts "pass."

print "test2:add_node..."
n = Network.new
node = n.add_node(1)
n.add_node(1)
n.add_node(1)
n.add_node(1)
n.add_node(1)
n.add_node(2)
n.add_node(3)
n.add_node(-1)
if node.id == 1 && n.nodes[0].id != node.id
  error
end
if n.nodes.size != 4
  error "size"
end
puts "pass."

print "test3:add_nodes..."
n = Network.new
nodes = n.add_nodes([1,2,3])
if n.nodes.size != 3 && n.nodes.size != nodes.size
  error "size"
end
puts "pass."

puts "all test passed!"

