# 2つのWebコミュニティファイルを解析して
# 再現率、適合率、F値を求めるクラス

class Analysis

  # 初期化メソッド
  # file: 初期コミュニティファイルパス
  # file1: X日後のフルクロールコミュニティファイルパス
  # file2: X日後の局所クロールコミュニティファイルパス
  def initialize(file,file1,file2)
    @com_filepath = file
    @com1_filepath = file1
    @com2_filepath = file2
    @hashs = get_hashs(@com_filepath)
    @hashs1 = get_hashs(@com1_filepath)
    @hashs2 = get_hashs(@com2_filepath)
    @add_hashs1 = get_add_hashs(@hashs,@hashs1)
    @add_hashs2 = get_add_hashs(@hashs,@hashs2)
    @drop_hashs1 = get_drop_hashs(@hashs,@hashs1)
    @drop_hashs2 = get_drop_hashs(@hashs,@hashs2)
    @cha_hashs1 = get_cha_hashs(@hashs,@hashs1)
    @cha_hashs2 = get_cha_hashs(@hashs,@hashs2)
  end

  # コミュニティ再現率を取得
  def get_community_recall
    recall = get_recall(@hashs1, @hashs2)
  end

  # フルクロールコミュニティの増加数を取得
  def get_addition_num1
    addition_num = @add_hashs1.size
  end

  # 局所クロールコミュニティの増加数を取得
  def get_addition_num2
    addition_num = @add_hashs2.size
  end

  # フルクロールコミュニティの減少数を取得
  def get_addition_num1
    drop_num = @drop_hashs1.size
  end

  # 局所クロールコミュニティの減少数を取得
  def get_drop_num2
    drop_num = @drop_hashs2.size
  end

  # 減少数を取得
  def get_drop_num
  end

  # 増加分再現率を取得
  def get_addition_recall
    recall = get_recall(@add_hashs1, @add_hashs2)
  end

  # 減少分再現率を取得
  def get_drop_recall
    recall = get_recall(@drop_hashs1, @drop_hashs2)
  end

  # 変化分再現率を取得
  def get_change_recall
    recall = get_recall(@cha_hashs1, @cha_hashs2)
  end

  # コミュニティ適合率を取得
  def get_community_precision
    precision = get_precision(@hashs1, @hashs2)
  end

  # 増加分適合率を取得
  def get_addition_precision
    precision = get_precision(@add_hashs1, @add_hashs2)
  end

  # 減少分適合率を取得
  def get_drop_precision
    precision = get_precision(@drop_hashs1, @drop_hashs2)
  end

  # 変化分適合率を取得
  def get_change_precision
    precision = get_precision(@cha_hashs1, @cha_hashs2)
  end

  # F値を取得
  # r: 再現率
  # p: 適合率
  def get_f(r,p)
    f = ((r*p*2)/(r+p)).round(2)
  end


  private

  # コミュニティデータを取得するメソッド
  # filepath: コミュニティファイルパス
  def get_hashs(filepath)
    hashs = Hash.new()
    open(filepath) {|file|
      while l = file.gets
        hashs[l.split(",")[0].to_i] = 1
        hashs[l.split(",")[1].to_i] = 1
      end
    }
    hashs
  end

  # 再現率を取得するメソッド
  # hashs1: 正解クラスタデータ
  # hashs2: 対象クラスタデータ
  def get_recall(hashs1, hashs2)
    r_nodes = []
    hashs1.each do |key1, value1|
      if hashs2[key1] == 1
        r_nodes << key1
      end
    end
    recall = (r_nodes.size/hashs1.size.to_f*100).round(2)
  end

  # 適合率を取得するメソッド
  # hashs1: 正解クラスタデータ
  # hashs2: 対象クラスタデータ
  def get_precision(hashs1, hashs2)
    p_nodes = []
    hashs1.each do |key1, value1|
      if hashs2[key1] == 1
        p_nodes << key1
      end
    end
    recall = (p_nodes.size/hashs2.size.to_f*100).round(2)
  end

  # 初期コミュニティから追加されたページを取得するメソッド
  # hashs1: 初期コミュニティデータ
  # hashs2: X日後コミュニティデータ
  def get_add_hashs(hashs1,hashs2)
    hashs = []
    hashs2.each do |key2, value2|
      if hashs1[key2] == nil
        hashs << key2
      end
    end
    hashs
  end

  # 初期コミュニティから除かれたページを取得するメソッド
  # hashs1: 初期コミュニティデータ
  # hashs2: X日後コミュニティデータ
  def get_drop_hashs(hashs1,hashs2)
    hashs = []
    hashs1.each do |key1, value1|
      if hashs2[key1] == nil
        hashs << key1
      end
    end
    hashs
  end

  # 初期コミュニティから変化したページを取得するメソッド
  # hashs1: 初期コミュニティデータ
  # hashs2: X日後コミュニティデータ
  def get_cha_hashs(hashs1,hashs2)
    hashs = []
    hashs1.each do |key1, value1|
      if hashs2[key1] == nil
        hashs << key1
      end
    end
    hashs2.each do |key2, value2|
      if hashs1[key2] == nil
        hashs << key2
      end
    end
    hashs
  end

end
