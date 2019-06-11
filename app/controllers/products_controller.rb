class ProductsController < ApplicationController

  require 'open-uri'
  require 'peddler'

  before_action :authenticate_user!, :except => [:regist]
  protect_from_forgery :except => [:regist]

  def show
    @login_user = current_user
  end

  def search
    if request.post? then
      request = params[:data]
      request = JSON.parse(request)
      data = request[0]
      counter = request[1]

      logger.debug("========================")
      logger.debug("No. " + counter.to_s)
      logger.debug(data)
      result = Array.new
      data.each_with_index do |row, index|
        logger.debug("+++++++++++++++++++++++++++++++++")
        logger.debug(row)
        buf = nil
        url = row[0]
        if url != nil && url != '' then
          buf = Array.new
          if url.include?("auctions.yahoo") then
            logger.debug("====== Yahoo Auction =======")

            charset = nil
            html = open(url) do |f|
              charset = f.charset # 文字種別を取得
              f.read # htmlを読み込んで変数htmlに渡す
            end
            doc = Nokogiri::HTML.parse(html, nil, charset)
            if doc.xpath('//p[@class="ptsFin"]')[0] == nil then
              #商品が出品中の場合
              title = doc.xpath('//h1[@class="ProductTitle__text"]').text.gsub("\n","")
              productinfo = doc.xpath('//li[@class="ProductDetail__item"]')
              condition = /<th class="ProductTable__th">状態<\/th>([\s\S]*?)\/li>/.match(html)
              if condition != nil then
                condition = condition[1]
                condition = /<li class="ProductTable__item">([\s\S]*?)</.match(condition)[1]
                condition = condition.gsub(/\R/, "")
                condition = condition.strip
              end
              k = 0
              while k < productinfo.length
                str = productinfo[k].text
                if str.include?("オークションID") == true then
                  auctionID = productinfo[k].inner_html.match(/pan>([\s\S]*?)<\/dd/)[1]
                end
                k += 1
              end
              k = 0

              priceType = doc.xpath('//div[@class="Price Price--current"]//dd[@class="Price__value"]')
              if priceType[0] != nil then
                listPrice = priceType[0].text.gsub("\n","")
                if listPrice.include?("（税 0 円）") == true then
                  listPrice = listPrice.gsub(/（税 0 円）/,"")
                  listPrice = CCur(listPrice)
                else
                  listPrice = listPrice.match(/税込([\s\S]*?)円/)[1]
                  listPrice = CCur(listPrice)
                end
              else
                listPrice = 0
              end

              priceType = doc.xpath('//div[@class="Price Price--buynow"]//dd[@class="Price__value"]')
              if priceType[0] != nil then
                binPrice = priceType[0].text.gsub("\n","")
                if binPrice.include?("（税 0 円）") == true then
                  binPrice = binPrice.gsub(/（税 0 円）/,"")
                  binPrice = CCur(binPrice)
                else
                  binPrice = binPrice.match(/税込([\s\S]*?)円/)[0]
                  binPrice = binPrice.gsub(/税込/,"")
                  binPrice = CCur(binPrice)
                end
              else
                binPrice = 0
              end

              bitnum = doc.xpath('//dd[@class="Count__number"]')[0].text
              bitnum = bitnum.slice(0,bitnum.length-4)

              restTime = doc.xpath('//dd[@class="Count__number"]')[1].text
              restTime = restTime.slice(0,restTime.length-4)

              images = doc.xpath('//div[@class="ProductImage__inner"]')
              image = []

              k = 0

              while k < images.length
                str = images[k].inner_html
                image[k] = str.match(/src="([\s\S]*?)"/)[1]
                k += 1
              end
              logger.debug("-------")
              seller_id = doc.xpath('//span[@class="Seller__name"]/a/text()').text

              logger.debug(seller_id)

            else
              #オークションが終了している場合
              title = doc.xpath('//h1[@property="auction:Title"]')[0].text
              title = "[終了したオークション]" + title

              auctionID = doc.xpath('//td[@property="auction:AuctionID"]')[0]
              if auctionID != nil then
                auctionID = auctionID.text
              end
              condition = doc.xpath('//td[@property="auction:ItemStatus"]')[0]
              if condition != nil then
                condition = condition.text
                condition = condition.gsub(/\R/, "")
                condition = condition.strip
              end

              binPrice = ""
              checkTax = doc.xpath('//p[@class="decTxtTaxIncPrice"]')[0]
              if checkTax != nil then
                checkTax = checkTax.text
              end

              logger.debug(url)

              listPrice = doc.xpath('//p[@class="decTxtBuyPrice Price__value"]')[0]
              if listPrice != nil then
                listPrice = doc.xpath('//p[@class="decTxtBuyPrice Price__value"]')[0].text
              else
                listPrice = doc.xpath('//p[@class="decTxtAucPrice Price__value"]')[0].text
              end
              listPrice = CCur(listPrice)
              if listPrice != nil then
                if listPrice.include?("%") then
                  listPrice = /^([\s\S]*?)\s/.match(listPrice)[1]
                end
              end
              binPrice = 0
              bitnum = doc.xpath('//b[@property="auction:Bids"]')[0]
              if bitnum != nil then
                bitnum = bitnum.text
              end

              restTime = "終了"
              k = 0
              image = []
              while k < 3
                images = doc.xpath('//img[@id="imgsrc' + (k+1).to_s + '"]')
                if images[0] != nil then
                  image[k] = images[0].attribute("src").value
                end
                k += 1
              end
              logger.debug("---end----")
              seller_id =/出品者<\/th>([\s\S]*?)<\/a>/.match(html)[1]
              logger.debug("---end2----")
              logger.debug(seller_id)
              seller_id =/" >([\s\S]*?)$/.match(seller_id)[1]
              logger.debug(seller_id)
            end

            title = title.gsub("\t", "")

            if image[0] != nil then
              im = '<img src="' + image[0].to_s  + '" style="height: 50px; margin:auto" >'
            else
              im = ''
            end

            buf = [url, im, title, auctionID, listPrice, binPrice, condition, bitnum, restTime]
            (0..7).each do |int|
              if image[int] != nil then
                buf.push(image[int])
              else
                buf.push("")
              end
            end
            buf.push(seller_id)

          elsif url.include?("otamart") then
            logger.debug("====== Otamart =======")

            if url[-1] != "/" then
              url = url + "/"
            end
            logger.debug(url)
            option = {
              "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
              "Connection" => "keep-alive",
              "Accept" => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'
            }
            html = open(url, option) do |f|
              charset = f.charset # 文字種別を取得
              f.read # htmlを読み込んで変数htmlに渡す
            end

            title = /"name": "([\s\S]*?)"/.match(html)[1]
            if html.include?("売り切れました") then
              title = "[終了済み] " + title
            end

            logger.debug("========= INFO ==========")
            item_id = /items\/([\s\S]*?)\//.match(url)[1]
            price = /"price": "([\s\S]*?)"/.match(html)[1]

            condition = /<p>商品の状態<\/p>([\s\S]*?)<\/div>/.match(html)[1]
            condition = /<p>([\s\S]*?)<\/p>/.match(condition)[1]

            seller = /"seller": \{([\s\S]*?)\}/.match(html)[1]
            seller_name = /"name": "([\s\S]*?)"/.match(seller)[1]

            image_set = /class="item-thumbnail"([\s\S]*?)class="item-detail/.match(html)[1]
            images = image_set.scan(/src="([\s\S]*?)"/)

            k = 0
            image = []
            while k < 8
              if images[k] != nil then
                image[k] = images[k][0].gsub("-thumbnail", "")
              else
                image[k] = ""
              end
              k += 1
            end

            if image[0] != nil then
              im = '<img src="' + image[0].to_s  + '" style="height: 50px; margin:auto" >'
            else
              im = ''
            end
            buf = [url, im, title, item_id, price, 0, condition, "-", "-"]
            (0..7).each do |int|
              if image[int] != nil then
                buf.push(image[int])
              else
                buf.push("")
              end
            end
            buf.push(seller_name)

          elsif url.include?("fril") then
            logger.debug("====== Fril =======")
            option = {
              "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
              "Connection" => "keep-alive",
              "Accept" => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'
            }
            html = open(url, option) do |f|
              charset = f.charset # 文字種別を取得
              f.read # htmlを読み込んで変数htmlに渡す
            end

            title = /<h1 class="item__name">([\s\S]*?)<\/h1>/.match(html)[1]

            logger.debug("========= INFO ==========")
            item_id = /jp\/([\s\S]*?)$/.match(url)[1]
            price = /"price": "([\s\S]*?)"/.match(html)[1]

            if /商品の状態<\/th>([\s\S]*?)<\/tr>/.match(html) != nil then
              condition = /商品の状態<\/th>([\s\S]*?)<\/tr>/.match(html)[1]
              condition = /<td>([\s\S]*?)<\/td>/.match(condition)[1]
            else
              condition = "-"
              title = "[終了済み] " + title
            end

            seller_name = /user-name">([\s\S]*?)</.match(html)[1]

            image_set = /<div class="sp-slides">([\s\S]*?)<section/.match(html)
            if image_set != nil then
              image_set = image_set[1]
              images = image_set.scan(/src="([\s\S]*?)"/)

              k = 0
              image = []
              while k < 8
                if images[k] != nil then
                  image[k] = images[k][0].gsub("-thumbnail", "")
                else
                  image[k] = ""
                end
                k += 1
              end
            else
              image = []
              image_set = /<div id="photoFrame([\s\S]*?)<div/.match(html)
              if image_set != nil then
                image[0] = /src="([\s\S]*?)"/.match(image_set[0])[1]
              else
                image[0] = nil
              end
            end

            if image[0] != nil then
              im = '<img src="' + image[0].to_s  + '" style="height: 50px; margin:auto" >'
            else
              im = ''
            end
            buf = [url, im, title, item_id, price, 0, condition, "-", "-"]
            (0..7).each do |int|
              if image[int] != nil then
                buf.push(image[int])
              else
                buf.push("")
              end
            end
            buf.push(seller_name)

          end
        end
        if buf != nil then
          result.push(buf)
        else
          buf = Array.new
          (0..17).each do |pp|
            buf.push('')
          end
          result.push(buf)
        end
      end
      logger.debug("----------------------")
      logger.debug(result)
      render json: result
    end
  end


  def set_csv
    user_id = current_user.id

    @pdata = PriceTable.where(user_id: user_id).order("buy_price ASC NULLS LAST").group(:buy_price, :sell_price).pluck(:buy_price, :sell_price)
    @fdata = ListingTemplate.where(user_id: user_id).group(:key, :caption, :value).pluck(:key, :caption, :value)
    @tdata = ReplaceTable.where(user_id: user_id).group(:from_keyword, :to_keyword).pluck(:from_keyword, :to_keyword)
    @kdata = KeywordSet.where(user_id: user_id).group(:keyword, :brand_name, :manufacturer, :recommended_browse_nodes, :generic_keywords).pluck(:keyword, :brand_name, :manufacturer, :recommended_browse_nodes, :generic_keywords)
    @ndata = NgSeller.where(user_id: user_id).group(:seller_id).pluck(:seller_id)

    data = {title: @tdata, price: @pdata, fixed: @fdata, keyword: @kdata, ng: @ndata}
    logger.debug("==== Data Render =====")
    jdata = data.to_json.html_safe
    render json: jdata
  end

  def setup
    @login_user = current_user
    user = current_user.email
    user_id = current_user.id
    @keyword_sets = KeywordSet.where(user_id: user_id)
    @listing_templates = ListingTemplate.where(user_id: user_id)
    @ng_sellers = NgSeller.where(user_id: user_id).order("id ASC")
    @price_tables = PriceTable.where(user_id: user_id).order("buy_price ASC NULLS LAST")
    @replace_tables = ReplaceTable.where(user_id: user_id)

    if @price_tables.length == 0 then
      init = Array.new
      init.push([1,2980])
      init.push([1000,3980])
      init.push([2000,5980])
      init.push([3000,7800])
      init.push([4000,9800])
      init.push([5000,12000])
      init.push([6000,12000])
      init.push([7000,14000])
      init.push([8000,16000])
      init.push([9000,18000])
      init.push([10000,20000])
      init.push([11000,22000])
      init.push([12000,24000])
      init.push([13000,26000])
      init.push([14000,28000])
      init.push([15000,30000])
      init.push([16000,32000])
      init.push([17000,34000])
      init.push([18000,36000])
      init.push([19000,38000])
      init.push([20000,40000])
      init.push([21000,42000])
      init.push([22000,44000])
      init.push([23000,46000])
      init.push([24000,48000])
      init.push([25000,50000])
      init.push([26000,52000])
      init.push([27000,54000])
      init.push([28000,56000])
      init.push([29000,58000])
      init.push([30000,60000])
      init.push([40000,80000])
      init.push([50000,100000])
      init.push([60000,120000])
      init.push([70000,140000])
      init.push([80000,160000])
      init.push([90000,180000])
      init.push([100000,200000])

      init.each do |row|
        PriceTable.create(user_id: user_id, buy_price: row[0], sell_price: row[1])
      end
    end

    @pdata = PriceTable.where(user_id: user_id).order("buy_price ASC NULLS LAST").group(:buy_price, :sell_price).pluck(:buy_price, :sell_price).to_json.html_safe
    @fdata = ListingTemplate.where(user_id: user_id).group(:key, :caption, :value).pluck(:key, :caption, :value).to_json.html_safe
    @tdata = ReplaceTable.where(user_id: user_id).group(:from_keyword, :to_keyword).pluck(:from_keyword, :to_keyword).to_json.html_safe
    @kdata = KeywordSet.where(user_id: user_id).group(:keyword, :brand_name, :manufacturer, :recommended_browse_nodes, :generic_keywords).pluck(:keyword, :brand_name, :manufacturer, :recommended_browse_nodes, :generic_keywords).to_json.html_safe
    temp = NgSeller.where(user_id: user_id).group(:id, :seller_id).pluck(:id, :seller_id)
    sorted = temp.sort {|a, b|
      a[0] <=> b[0] # 価格ソート
    }
    buf = Array.new
    sorted.each do |tp|
      tt = Array.new
      tt[0] = tp[1]
      buf.push(tt)
    end
    @ndata = buf.to_json.html_safe

    logger.debug(@ndata)
    if request.post? then
      data = JSON.parse(params[:data])

      pdata = data["price"]
      fdata = data["fixed"]
      tdata = data["title"]
      kdata = data["keyword"]
      ndata = data["ng"]

      #定型パラメータの設定
      fdata.each do |fd|
        fkey = fd[0]
        fcp = fd[1]
        fvl = fd[2]
        if fkey != nil && fkey != '' then
          temp = ListingTemplate.find_or_create_by(user_id: user_id, key: fkey)
          temp.update(
            caption: fcp,
            value: fvl
          )
        else
          break
        end
      end

      #除外セラーの設定
      NgSeller.where(user_id: user_id).delete_all
      ndata.each do |nd|
        nkey = nd[0]
        if nkey != nil && nkey != '' then
          temp = NgSeller.find_or_create_by(user_id: user_id, seller_id: nkey)
        else
          break
        end
      end

      #キーワードの設定
      KeywordSet.where(user_id: user_id).delete_all
      kdata.each do |kd|
        nkey = kd[0]
        if nkey != nil && nkey != '' then
          temp = KeywordSet.find_or_create_by(user_id: user_id, keyword: nkey)
          temp.update(
            brand_name: kd[1],
            manufacturer: kd[2],
            recommended_browse_nodes: kd[3],
            generic_keywords: kd[4]
          )
        else
          break
        end
      end

      #価格の設定
      pdata.each do |kd|
        nkey = kd[0]
        if nkey != nil && nkey != '' then
          temp = PriceTable.find_or_create_by(user_id: user_id, buy_price: nkey)
          temp.update(
            sell_price: kd[1]
          )
        else
          break
        end
      end

      #置換テーブルの設定
      ReplaceTable.where(user_id: user_id).delete_all
      tdata.each do |kd|
        nkey = kd[0]
        if nkey != nil && nkey != '' then
          temp = ReplaceTable.find_or_create_by(user_id: user_id, from_keyword: nkey)
          temp.update(
            to_keyword: kd[1]
          )
        else
          break
        end
      end
      redirect_to products_setup_path
    end
  end

  def prepare
    @login_user = current_user
    user = current_user.email
    logger.debug(current_user.id)
    @account = current_user.account
    if @account == nil then
      @account = Account.create(
        user_id: current_user.id
      )
    end
    if request.post? then
      @account.update(account_params)
    end
  end


  def upload
    user_id = current_user.id
    user = Account.find_by(user_id: user_id)
    aws = user.aws_access_key_id
    skey = user.secret_key
    seller = user.seller_id

    res = params[:data]

    client = MWS.feeds(
      marketplace: "A1VC38T7YXB528",
      merchant_id: seller,
      aws_access_key_id: aws,
      aws_secret_access_key: skey
    )

    res1 = JSON.parse(res)

    kk = 0
    feed_body = ""
    while kk < res1.length
      feed_body = feed_body + res1[kk].join("\t")
      feed_body = feed_body + "\n"
      kk += 1
    end

    new_body = feed_body.encode(Encoding::Windows_31J)

    feed_type = "_POST_FLAT_FILE_LISTINGS_DATA_"
    parser = client.submit_feed(new_body, feed_type)
    doc = Nokogiri::XML(parser.body)

    submissionId = doc.xpath(".//mws:FeedSubmissionId", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text

    process = ""
    err = 0
    render json: res
  end

  def regist
    if request.post? then
      logger.debug("====== Regist from Form Start =======")
      user = params[:user]
      password = params[:password]
      if User.find_by(email: user) == nil then
        #新規登録
        init_password = password
        tuser = User.create(email: user, password: init_password, admin_flg: false)
        return
      end
    end
  end


  private
  def account_params
     params.require(:account).permit(:user_id, :seller_id, :mws_auth_token, :aws_access_key_id, :secret_key)
  end

  def CCur(value)
    res = value.gsub(/\,/,"")
    res = res.gsub(/円/,"")
    return res
  end

end
