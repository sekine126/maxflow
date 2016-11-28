require 'pp'

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

# コミュニティデータをファイルから取得
db_name = params["d"]
link1_date = params["f"]
link2_date = params["t"]
links1 = []
links2 = []
nodes1 = []
nodes2 = []
link1_filename = "./data/crawl/#{db_name}_crawl_#{link1_date}.txt"
link2_filename = "./data/update/hits_#{db_name}_#{link1_date}_#{link2_date}.txt"
# 初期データ
open(link1_filename) {|file|
  while l = file.gets
    links1 << l.chomp
    l.split(",").each do |h|
      nodes1 << h
    end
  end
}
nodes1.uniq!
# 指定した日付のデータ
open(link2_filename) {|file|
  while l = file.gets
    links2 << l.chomp
    l.split(",").each do |h|
      nodes2 << h
    end
  end
}
nodes2.uniq!

# 結果をファイル出力
file = File.open("./data/compare/hits_#{db_name}_#{link1_date}_#{link2_date}.txt", "w")
new_links = []
new_nodes = []
links2.each do |link2|
  flag = 0
  links1.each do |link1|
    # 初期コミュニティにもある場合はそのまま出力
    if link1 == link2
      file.puts(link2)
      flag = 1
      links1.delete(link1)
    end
  end
  # 初期コミュニティになかった場合は+をつけて出力
  if flag == 0
    file.puts("+#{link2}")
    new_links << link2
  end
end
# 初期コミュニティから消えているものはカッコをつけて出力
links1.each do |link1|
  file.puts("(#{link1})")
end
file.close

# コミュニティに新しく追加されたノード数を画面に表示
nodes2.each do |node2|
  # 新しく追加されたノードの場合は配列に格納
  if !(nodes1.include?(node2))
    new_nodes << node2
  end
end
puts "New #{new_nodes.size} nodes."

# 新しく追加されたリンク数を画面に表示
puts "New #{new_links.size} links."

# 出リンクを持っているノードとその出現数を画面に表示
puts "Node list it has same outlinks"
# 出現数を記憶するハッシュ配列
hash = Hash.new(0)
# リンク元ノードのそれぞれの出現数を取得する
nodes2.each do |node2|
  hash[node2] = 0
  links2.each do |link2|
    if node2 == link2.split(",")[0]
      hash[node2] += 1
    end
  end
end
# リンク元ノードのリストを作成
from_nodes = []
links2.each do |link2|
  from_nodes << link2.split(",")[0]
end
from_nodes.uniq!
# 新しく追加されたノードにはnewをつけて画面に出力
from_nodes.each do |from_node|
  if new_nodes.include?(from_node)
    puts "#{hash[from_node]} new : #{from_node}"
  else
    puts "#{hash[from_node]} : #{from_node}"
  end
end

