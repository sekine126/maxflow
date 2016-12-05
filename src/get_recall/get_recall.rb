# 初期コミュニティと指定した日付のフルクロール時のコミュニティを比較して
# どれだけ変化しているかを表示するプログラム

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
nodes1 = []
nodes2 = []
links1 = []
links2 = []
nodes1_hash = Hash.new()
nodes2_hash = Hash.new()
links1_hash = Hash.new()
links2_hash = Hash.new()
link1_filename = "./data/crawl/#{db_name}_crawl_#{date1}.txt"
link2_filename = "./data/crawl/#{db_name}_crawl_#{date2}.txt"

# 初期コミュニティデータ
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

# 指定した日付のフルクロールで取得したコミュニティデータ
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

# それぞれのコミュニティのノード、リンク数を出力
puts "community1: #{nodes1.size} nodes, #{links1.size} links."
puts "community2: #{nodes2.size} nodes, #{links2.size} links."

# 初期コミュニティからノード数がどれだけ変化したか表示
plus_nodes = []
minus_nodes = []
continue_nodes = []
nodes1.each do |node1|
  if nodes2_hash[node1] == 1
    continue_nodes << node1
  else
    minus_nodes << node1
  end
end
nodes2.each do |node2|
  if nodes1_hash[node2] == nil
    plus_nodes << node2
  end
end
puts "Plus #{plus_nodes.size} nodes."
puts "Minus #{minus_nodes.size} nodes."
puts "Continue #{continue_nodes.size}/#{nodes1.size} nodes."

# 初期コミュニティからリンク数がどれだけ変化したか表示
plus_links = []
minus_links = []
continue_links = []
links1.each do |link1|
  if links2_hash[link1] == 1
    continue_links << link1
  else
    minus_links << link1
  end
end
links2.each do |link2|
  if links1_hash[link2] == nil
    plus_links << link2
  end
end
puts "Plus #{plus_links.size} links."
puts "Minus #{minus_links.size} links."
puts "Continue #{continue_links.size}/#{links1.size} links."

