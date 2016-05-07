# Label の [0, 1] 表を作る
require "csv"
load "./models.rb"

labels_count = Label.count
CSV.open("tmp.csv", "w") do |csv|
  csv << Label.all.pluck(:name)
  User.includes(:users_labels).each do |user|
    labels = Array.new(labels_count, 0)
    user.users_labels.map(&:label_id).each do |label_id|
      labels[label_id - 1] = 1
    end
    id = user.name.match(/\d+/)[0]
    csv << [id] + labels
  end
end
