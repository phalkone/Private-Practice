class AddContactInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :address, :string
    add_column :users, :postcode, :string
    add_column :users, :town, :string
    add_column :users, :phone, :string
    add_column :users, :mobile, :string
  end

  def self.down
    remove_column :users, :mobile
    remove_column :users, :phone
    remove_column :users, :town
    remove_column :users, :postcode
    remove_column :users, :address
  end
end
