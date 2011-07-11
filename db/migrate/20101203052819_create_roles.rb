class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :title
    end

    create_table :roles_users, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end

  end

  def self.down
    drop_table :roles
    drop_table :roles_users
    Role.delete_all
  end
end
