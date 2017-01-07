
params = ARGV.getopts('d:f:t:')
if params["d"] == nil
  puts "Error: Please set -d database name."
  exit(1)
end
if params["f"] == nil
  puts "Error: Please set -f date option."
  exit(1)
end
if params["f"] != nil && params["f"].size != 8 
  puts "Error: -f is date. e.g. 20150214"
  exit(1)
end
if params["t"] == nil
  puts "Error: Please set -t date option."
  exit(1)
end
if params["t"] != nil && params["f"].size != 8 
  puts "Error: -t is date. e.g. 20150214"
  exit(1)
end

# 差分データをファイルから取得
db_name = params["d"]
date1 = params["f"]
date2 = params["t"]
nodes = []
nodes1 = []
nodes2 = []
links = []
links1 = []
links2 = []
nodes_hash = Hash.new()
links_hash = Hash.new()
nodes1_hash = Hash.new()
links1_hash = Hash.new()
nodes2_hash = Hash.new()
links2_hash = Hash.new()
link_filename = "./data/crawl/#{db_name}_crawl_#{date1}.txt"
link1_filename = "./data/crawl/#{db_name}_crawl_#{date2}.txt"
link2_filename = "./data/update/ran_#{db_name}_#{date1}_#{date2}.txt"
# 初期コミュニティデータ
open(link_filename) {|file|
  while l = file.gets
    links << l.chomp
    nodes << l.split(",")[0].to_i
    nodes << l.split(",")[1].to_i
    links_hash[l.chomp] = 1
    nodes_hash[l.split(",")[0].to_i] = 1
    nodes_hash[l.split(",")[1].to_i] = 1
  end
}
nodes.uniq!
links.uniq!

# 指定した日付のフルクロールで取得したコミュニティデータ
open(link1_filename) {|file|
  while l = file.gets
    links1 << l.chomp
    nodes1 << l.split(",")[0].to_i
    nodes1 << l.split(",")[1].to_i
    links1_hash[l.chomp] = 1
    nodes1_hash[l.split(",")[0].to_i] = 1
    nodes1_hash[l.split(",")[1].to_i] = 1
  end
}
nodes1.uniq!
links1.uniq!

# 指定した日付の局所クロールで更新したコミュニティデータ
open(link2_filename) {|file|
  while l = file.gets
    links2 << l.chomp
    nodes2 << l.split(",")[0].to_i
    nodes2 << l.split(",")[1].to_i
    links2_hash[l.chomp] = 1
    nodes2_hash[l.split(",")[0].to_i] = 1
    nodes2_hash[l.split(",")[1].to_i] = 1
  end
}
nodes2.uniq!
links2.uniq!

# 初期コミュニティから新しく追加されたページを抽出
new_nodes1 = []
new_nodes2 = []
nodes1.each do |node1|
  if nodes_hash[node1] == nil
    new_nodes1 << node1
  end
end
nodes2.each do |node2|
  if nodes_hash[node2] == nil
    new_nodes2 << node2
  end
end

# 初期コミュニティから新しく減ったページを抽出
drop_nodes1 = []
drop_nodes2 = []
nodes.each do |node|
  if nodes1_hash[node] == nil
    drop_nodes1 << node
  end
  if nodes2_hash[node] == nil
    drop_nodes2 << node
  end
end

community_recall = get_com_recall(nodes1, nodes2)
puts "Community Recall #{community_recall} %"

# コミュニティの再現率を取得
def get_com_recall(nodes1, nodes2)
  recall_of_nodes = []
  nodes1.each do |node1|
    if nodes2_hash[node1] == 1
      com_recall_of_nodes << node1
    end
  end
  recall = (recall_of_nodes.size/nodes1.size.to_f*100).round(2)
end

# コミュニティの適合率を表示
com_precision_of_nodes = []
nodes1.each do |node1|
  if nodes2_hash[node1] == 1
    com_precision_of_nodes << node1
  end
end
precision = (com_precision_of_nodes.size/nodes2.size.to_f*100).round(2)
puts "Community Precision #{precision} %"

# コミュニティのF値を表示
puts "Community F #{((recall*precision*2)/(recall+precision)).round(2)} "

# 増分再現率を表示
recall_nodes = []
add_nodes = []
new_nodes1.each do |nnode1|
  if new_nodes2.include?(nnode1)
    recall_nodes << nnode1
  end
end
puts "New node Recall #{(recall_nodes.size/new_nodes1.size.to_f*100).round(2)} %"
