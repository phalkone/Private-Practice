class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :permalink
      t.boolean :nested, :default => false
      t.integer :sequence
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
