# Label の [0, 1] 表を作る
require "csv"
load "./models.rb"

# CSV.open("tmp.csv", "w") do |csv|
#   csv << ["name", "income", "reply", "count"]
#   company_ids_names = Company.all.map { |x| [x.id, x.name] }.to_h
#   info = UsersCompany.group(:company_id, :income, :reply).count.map { |k, v| k + [v] }
#   info.each do |company_id, income, reply, count|
#     company_name = company_ids_names[company_id]
#     csv << [company_name, income, reply, count]
#   end
# end

`sqlite3 -separator ',' -header job-draft.sqlite3 "select name, user_id, income, reply from users_companies uc inner join companies c on c.id = uc.company_id" > tmp.csv`

`R --slave --no-save --no-restore < ./company_reply.rscript`
