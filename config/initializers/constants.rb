require 'csv'

module Constants
  ## Constants::NUMでアクセスできる
  temp = []
  CSV.foreach('app/others/Flat.File.Toys.jp.csv', nil_value: "") do |row|
    # 行に対する処理
    temp.push(row)
  end
  AH = temp
end
