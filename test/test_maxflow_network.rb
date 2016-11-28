require './src/maxflow_network.rb'
require './test/error.rb'

print "test1:set_seeds..."
m = MaxflowNetwork.new
m.add_nodes([1,2,3,4,5])
list = []
m.set_seeds(list)
if m.seeds.size != 0
  error "set empty"
end
list = [1]
m.set_seeds(list)
if m.seeds.size != 1 && m.seeds[0].id != 0
  error
end
list = [1,2,3,4,5]
m.set_seeds(list)
if m.seeds.size != 5
  error
end
puts "pass."

print "test2:maxflow..."
m = MaxflowNetwork.new
data = [[1,4],[2,5],[2,6],[3,6],[4,7],[4,8],[4,9],[5,6],[5,9],[5,10],[6,10],[6,11]]
data.each do |d|
  m.connect(d[0],d[1])
end
p m.edges
m.set_seeds([1,2,3])
m.maxflow
puts "pass."

print "test3:get_community..."
community = m.get_community
puts "pass."
p community

print "test4:maxflow with reciprocal link..."
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

