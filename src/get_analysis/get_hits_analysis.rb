# 2つのWebコミュニティファイルから再現率、適合率、F値を求めるプログラム
# bundle exec ruby src/get_analysis/get_random_analysys.rb -d sample -f 20161220 -t 20161221
# -d データベースネーム
# -f 日付1
# -t 日付2
require "./src/get_analysis/analysis.rb"

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

# コマンドライン引数を取得
db_name = params["d"]
date1 = params["f"]
date2 = params["t"]

# ファイルパスを作成
filepath = "./data/crawl/#{db_name}_crawl_#{date1}.txt"
filepath1 = "./data/crawl/#{db_name}_crawl_#{date2}.txt"
filepath2 = "./data/update/hits_#{db_name}_#{date1}_#{date2}.txt"

# 解析クラスのインスタンスメソッドを作成
analysis = Analysis.new(filepath, filepath1, filepath2)

# コミュニティ再現率を表示
community_recall = analysis.get_community_recall()
puts "Community Recall #{community_recall} %"

# コミュニティ適合率を表示
community_precision = analysis.get_community_precision()
puts "Community Precision #{community_precision} %"

# コミュニティF値を表示
community_f = analysis.get_f(community_recall, community_precision)
puts "Community F #{community_f}"

# 増加分再現率を表示
addition_recall = analysis.get_addition_recall
puts "Addition Recall #{addition_recall} %"

# 増加分適合率を表示
addition_precision = analysis.get_addition_precision
puts "Addition Precision #{addition_precision} %"

# 増加分F値を表示
addition_f = analysis.get_f(addition_recall, addition_precision)
puts "Addition F #{addition_f}"

# 減少分再現率を表示
drop_recall = analysis.get_drop_recall
puts "Drop Recall #{drop_recall} %"

# 減少分適合率を表示
drop_precision = analysis.get_drop_precision
puts "Drop Precision #{drop_precision} %"

# 減少分F値を表示
drop_f = analysis.get_f(drop_recall, drop_precision)
puts "Drop F #{drop_f}"

# 変化分再現率を表示
change_recall = analysis.get_change_recall
puts "Change Recall #{change_recall} %"

# 変化分適合率を表示
change_precision = analysis.get_change_precision
puts "Change Precision #{change_precision} %"

# 変化分F値を表示
change_f = analysis.get_f(change_recall, change_precision)
puts "Change F #{change_f}"
