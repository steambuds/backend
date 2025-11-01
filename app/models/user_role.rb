class UserRole < ApplicationRecord
  belongs_to :user

  enum :role, { admin: "admin", server_machine: "server_machine", manager: "manager" }, validate: true

  validates :role, uniqueness: { scope: :user_id, message: "has already been assigned to this user" }
end
