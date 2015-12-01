require './src/maxflow_network.rb'
require './test/error.rb'

print "test1:connect..."
n = MaxflowNetwork.new
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

print "test3:set_seeds..."
m = MaxflowNetwork.new
m.add_nodes([1,2,3,4,5])
list = []
m.set_seeds(list)
if m.seeds.size != 0
  error "set empty"
end
list = [1]
m.set_seeds(list)
if m.seeds.size != 1 && m.seeds[0].id != 1
  error
end
list = [1,2,3,4,5]
m.set_seeds(list)
if m.seeds.size != 5 && m.seeds[0].id != 1 && m.seeds[1].id != 2
  error
end
if m.seeds[2].id != 3 && m.seeds[3].id != 4 && m.seeds[4].id != 5
  error
end
puts "pass."

print "test4:maxflow..."
m = MaxflowNetwork.new
m.add_nodes([1,2,3,4,5,6,7,8,9,10,11])
data = [[1,4],[2,5],[2,6],[3,6],[4,7],[4,8],[4,9],[5,6],[5,9],[5,10],[6,10],[6,11]]
data.each do |d|
  m.connect(d[0],d[1])
end
m.set_seeds([1,2,3])
m.maxflow
puts "pass."

print "test5:get_community..."
community = m.get_community
puts "pass."

print "test6:maxflow with reciprocal link..."
m = MaxflowNetwork.new
m.add_nodes([1,2,3,4,5,6,7,8,9,10,11])
data = [[1,4],[2,5],[2,6],[3,6],[4,7],[4,8],[4,9],[5,6],[5,9],[5,10],[6,10],[6,11],[1,2],[2,1],[1,3],[3,1]]
data.each do |d|
  m.connect(d[0],d[1])
end
m.set_seeds([1,2,3])
m.maxflow
puts "pass."

puts "all test passed!"

