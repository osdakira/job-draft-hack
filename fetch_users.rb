# bundle exec ruby parse.rb
# http://qiita.com/seiya1121/items/3dde2dae7319fe261323
require 'open-uri' # URLにアクセスする為のライブラリを読み込みます。
require 'nokogiri' # Nokogiriライブラリを読み込みます。
require "sqlite3"
require "csv"

def get_page_by(url)
  sleep 2
  charset = nil
  html = open(url) do |f|
    charset = f.charset #文字種別を取得します。
    f.read # htmlを読み込み変数htmlに渡します。
  end
  Nokogiri::HTML.parse(html, nil, charset) # htmlを解析し、オブジェクト化
end

def pickup_users_by(page)
  tr_list = page.css(".user-ranking-table tbody tr")
  max = tr_list.size
  tr_list.map.with_index do |tr, i|
    name, age, _, num_nomination, _ = tr.css("td").map(&:text)
    # tags_psv, companies_psv = fetch_more_user_info(name)
    # [name, age, num_nomination, tags_psv, companies_psv]
    [name, age, num_nomination]
  end
end

def fetch_more_user_info(name)
  id = name.match(/\d+/)[0]
  url = "https://job-draft.jp/users/#{id}"
  page = get_page_by url
  tags = extract_tags page
  tags_psv = tags.join("|")

  companies = extract_companies page
  companies_psv = companies.join("|")
  [tags_psv, companies_psv]
end

def extract_tags(page)
  tags = page.css(".p-aside-box:nth-child(3) .p-aside-row:nth-child(4) .p-aside-row__body").text().split
  tags.reject { |x| ["more", "+"].include? x }
end

def extract_companies(page)
  dd_list = page.css(".ibox-content .row dd")
  dd_list.map do |x|
    company_name = x.css(".company-name").text
    income = x.css(".notation").text.gsub /\+/, ""
    "#{company_name}+#{income}"
  end
end

def store(csv, users)
  users.each do |user|
    csv << user
  end
end

# ページにアクセスするたびに、返ってくるユーザーが異なる。
# よって、同じページに3回アクセスし、id でユニークにする。偶然に頼るしかない
# 非安定ソートを使っているか、わざとランダムにしているのかも？
def main
  base_url = "https://job-draft.jp/users"
  retry_times = 5
  pp = (1..24)

  users_list = pp.map do |i|
    retry_times.times.map do |j|
      print "\r search page #{i}. count #{j}."
      url = "#{base_url}?page=#{i}"
      page = get_page_by url
      pickup_users_by page
    end
  end

  user_ids_users = users_list.flatten(2).map { |x| [x.first, x] }.to_h
  csv = CSV.open("job-draft-users.csv", "a")
  store csv, user_ids_users.values
end

if __FILE__ == $0
  main
end
