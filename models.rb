require "active_record"
require "sqlite3"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'job-draft.sqlite3'
)

class User < ActiveRecord::Base
  has_many :users_companies
  has_many :companies, through: :users_companies
  has_many :users_labels
  has_many :labels, through: :users_labels
end

class Company < ActiveRecord::Base
  has_many :users_companies
  has_many :users, through: :users_companies
end

class Label < ActiveRecord::Base
  has_many :users_labels
  has_many :users, through: :users_labels
end

class UsersLabel < ActiveRecord::Base
  belongs_to :user
  belongs_to :label
end

class UsersCompany < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
end

def migration
  ActiveRecord::Migration.create_table :users do |t|
    t.string :name
    t.string :age
    t.integer :num_nomination
  end

  ActiveRecord::Migration.create_table :companies do |t|
    t.string :name
  end

  ActiveRecord::Migration.create_table :labels do |t|
    t.string :name
  end

  ActiveRecord::Migration.create_table :users_labels do |t|
    t.integer :user_id
    t.integer :label_id
  end

  ActiveRecord::Migration.create_table :users_companies do |t|
    t.integer :user_id
    t.integer :company_id
    t.string :income
    t.string :first_place
  end
end
