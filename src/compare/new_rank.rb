
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
if params["t"] != nil && params["t"].size != 8 
  puts "Error: -t is date. e.g. 20150214"
  exit(1)
end

db_name = params["d"]
score1_date = params["f"]
score2_date = params["t"]
score1_filename = "./data/new_rank/hits_#{db_name}_#{score1_date}.txt"
score2_filename = "./data/new_rank/hits_#{db_name}_#{score2_date}.txt"
hashs1 = []
hashs2 = []
scores1 = Hash.new()
scores2 = Hash.new()

# スコアランキングデータをファイルから取得
open(score1_filename) { |file|
  while l = file.gets
    l.chomp!
    next if l[0] == "#"
    hashs1 << l.split(",")[0].to_i
    scores1[l.split(",")[0].to_i] = l.split(",")[1].to_f
  end
}
hashs1.uniq!
open(score2_filename) { |file|
  while l = file.gets
    l.chomp!
    next if l[0] == "#"
    hashs2 << l.split(",")[0].to_i
    scores2[l.split(",")[0].to_i] = l.split(",")[1].to_f
  end
}
hashs2.uniq!

# ２つのファイルどちらにもあり、ハブスコアが０以外のノードを取得
ex_nodes = []
hashs1.each do |hash1|
  if scores1[hash1] != 0 && hashs2.include?(hash1)
    ex_nodes << hash1
  end
end

# 結果を出力
file = File.open("./data/compare/#{db_name}_#{params["f"]}_#{params["t"]}.txt", "w")
file.puts "# #{ex_nodes.size} Page"
ex_nodes.each do |ex_node|
  if scores2[ex_node] - scores1[ex_node] > 0
    file.puts"#{ex_node},#{scores2[ex_node] - scores1[ex_node]}"
  end
end
file.close

