require './src/network.rb'
require './test/error.rb'

print "test:connect..."
n = Network.new
e = n.connect(1,2)
e = n.connect(1,2)
e = n.connect(1,2)
if e.from != 1 && e.from != n.edges[0].from
  error "1"
end
if e.to != 2 && e.to != n.edges[0].to
  error "2"
end
n.nodes.each do |node|
    p node.out_edges
    p node.in_edges
  if node.id == 0
    if node.out_edges.size != 1
      error "3"
    end
  end
end

puts "pass."

puts "all test passed!"

