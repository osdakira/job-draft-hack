# bundle exec ruby ./convert_csv_to_sqlite3.rb

require "csv"
require "./models.rb"

def main
  CSV.foreach("job-draft.csv") do |row|
    name, age, num_nomination, tags_psv, companies_psv = row
    tags = tags_psv.split("|")
    companies_incomes = companies_psv.split("|").map { |companies_incomes_str|
      companies_incomes_str.split("+")
    }.to_h

    user = User.create(name: name, age: age, num_nomination: num_nomination)

    existed_labels = Label.where(name: tags)
    new_labels = (tags - existed_labels.map(&:name)).map do |name|
      Label.create(name: name)
    end
    user.labels = (existed_labels + new_labels)

    companies_incomes.each do |company_name, income_str|
      company = Company.find_or_create_by(name: company_name)
      income, first_place = income_str.split("級")
      user.users_companies.create(company: company, income: income,
        first_place: first_place)
    end
  end
end

def setup
  migration
rescue ActiveRecord::StatementInvalid
end

if __FILE__ == $0
  setup
  main
end
