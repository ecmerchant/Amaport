require 'csv'

module Constants
  ## Constants::NUMでアクセスできる
  temp = []
  CSV.foreach('app/others/Flat.File.Toys.jp.csv', nil_value: "") do |row|
    # 行に対する処理
    temp.push(row)
  end
  AH = temp

  HD = {
    item_url: "商品URL",
    item_image: "商品画像",
    title: "商品名",
    item_id: "商品ID",
    current_price: "販売価格",
    bin_price: "販売価格(即決)",
    condition: "商品状態",
    bid: "入札件数",
    left_time: "残り時間",
    image_url1: "画像URL1",
    image_url2: "画像URL2",
    image_url3: "画像URL3",
    image_url4: "画像URL4",
    image_url5: "画像URL5",
    image_url6: "画像URL6",
    image_url7: "画像URL7",
    image_url8: "画像URL8",
    seller_id: "出品者ID"
  }

end
