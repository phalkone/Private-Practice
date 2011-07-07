class AddMagicStatesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmed, :boolean, :null => false, :default => false
    add_column :users, :active, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :active
    remove_column :users, :confirmed
  end
end
