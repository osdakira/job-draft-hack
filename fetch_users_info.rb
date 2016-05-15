# bundle exec ruby fetch_users_info.rb

load "./fetch_users.rb"

# ラベルも、指名企業も、可変なので、`|` で区切ることにする
# psv = pipe separated values

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
  tags = page.css(".p-aside-box:nth-child(3) .p-aside-row:nth-child(4) .p-aside-row__body li").map(&:text)
  tags.reject { |x| ["more", "+"].include? x }
end

def extract_companies(page)
  companies = page.css(".ibox-content .row .read")
  companies.map do |x|
    company_name = x.css(".company-name").text
    reply = x.css(".label").text()
    income = x.css(".notation").text.gsub /\+/, ""
    "#{company_name}+#{income}+#{reply}"
  end
end

def main
  users = CSV.open("job-draft-users.csv", "r").readlines
  users_info_csv = CSV.open("job-draft-users-info.csv", "w")
  max = users.count * 1.0
  users.each.with_index do |row, i|
    percent = ((i * 100 / max) * 100).to_i / 100.0
    print "\r search #{percent}"
    name = row[0]
    tags_psv, companies_psv = fetch_more_user_info(name)
    users_info_csv << [name, tags_psv, companies_psv]
  end
end

if __FILE__ == $0
  main
end
