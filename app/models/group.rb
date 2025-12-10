class Group < ApplicationRecord
  has_paper_trail

  has_many :group_users
  has_many :users, through: :group_users
  has_many :attendances

  validates :name, presence: true
end
