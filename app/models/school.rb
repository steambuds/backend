class School < ApplicationRecord
  has_many :school_users, dependent: :destroy
  has_many :users, through: :school_users

  validates :school_name, presence: true
  validates :steamer_id, presence: true, uniqueness: true
end
