require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'fetch data correctly as created' do
    # hikakinTV
    url = 'https://www.youtube.com/user/HikakinTV'
    @link = Link.create(url: url)
    assert_not_nil @link

    assert_equal 'HikakinTV', @link.title
    assert_match 'ヒカキン', @link.description
    assert_not_empty @link.image

    # instagram
    url = 'https://www.instagram.com/'
    @link = Link.create(url: url)
    assert_not_nil @link

    assert_equal 'Instagram', @link.title
    assert_match 'Instagram', @link.description
    assert_not_empty @link.image

    # example.com (カード情報ない)
    url = 'http://example.com'
    @link = Link.create(url: url)
    assert_not_nil @link
    assert_equal 'Example Domain', @link.title
    assert_empty @link.description
  end

  test 'fetch nijie correctly' do
    url = 'https://sp.nijie.info/view_popup.php?id=319985'
    url = Link.normalize_url(url)
    @link = Link.create(url: url)

    assert_equal 'https://nijie.info/view.php?id=319985', @link.url
    assert_match '発情めめめ', @link.title

    url = 'https://nijie.info/view.php?id=319985'
    url = Link.normalize_url(url)
    assert_match @link.url, url

    # アニメはサムネに留めておく
    url = 'http://nijie.info/view.php?id=177736'
    url = Link.normalize_url(url)
    @link = Link.create(url: url)

    assert_match '__rs_l160x160', @link.image

    # cf: issue #59
    url = 'https://nijie.info/view.php?id=322323'
    url = Link.normalize_url(url)
    @link = Link.create(url: url)

    assert_equal 'https://pic.nijie.net/05/nijie_picture/3965_20190710041444_0.png', @link.image
  end

  test 'fetch pixiv correctly' do
    url = 'https://www.pixiv.net/member_illust.php?mode=medium&illust_id=75763842'
    @link = Link.create(url: url)

    assert_match '地鶏', @link.title
    assert_equal 'https://pixiv.cat/75763842.jpg', @link.image

    # これは完全に冗長なテストだけどかわいいから見て
    url = 'https://www.pixiv.net/member_illust.php?mode=medium&illust_id=73718144'
    @link = Link.create(url: url)

    assert_match 'んあー・・・', @link.title
    assert_match 'ん？あげませんよ！', @link.description
    assert_equal 'https://pixiv.cat/73718144.jpg', @link.image

    # manga. これで抜く人いなそう
    url = 'https://www.pixiv.net/member_illust.php?mode=medium&illust_id=75871400'
    @link = Link.create(url: url)

    assert_match 'DWU', @link.title
    assert_match '浅瀬', @link.description
    assert_equal 'https://pixiv.cat/75871400-1.jpg', @link.image
  end

  test 'fetch melonbooks correctly' do
    url = 'https://www.melonbooks.co.jp/detail/detail.php?product_id=319663'
    url = Link.normalize_url(url)
    @link = Link.create(url: url)

    assert_match 'adult_view', @link.url
    assert_match 'めちゃシコごちうさアソート', @link.title
    assert_match 'image=212001143963.jpg', @link.image
    assert_no_match 'c=1', @link.image
    assert_match 'めちゃシコシリーズ', @link.description

    # スタッフの推薦文ない作品は構造変わるからテスト
    url = 'https://www.melonbooks.co.jp/detail/detail.php?product_id=242938'
    url = Link.normalize_url(url)
    @link = Link.create(url: url)

    assert_match 'ぬめぬめ', @link.title
    assert_match '諏訪子様にショタがいじめられる話です。', @link.description #かわいそう…
  end

  test 'deal correctly with incorrect url' do
    url = 'http://not-val.id/'
    @link = Link.create(url: url)

    assert_equal @link.url, @link.title
  end
end
