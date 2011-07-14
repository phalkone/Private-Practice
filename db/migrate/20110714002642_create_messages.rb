class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id
      t.string :email
      t.string :name
      t.string :subject
      t.string :body
      t.boolean :read, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
