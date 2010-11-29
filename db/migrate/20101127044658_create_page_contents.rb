class CreatePageContents < ActiveRecord::Migration
  def self.up
    create_table :page_contents do |t|
      t.string :title
      t.text :body
      t.string :locale
      t.boolean :html, :default => false
      t.integer :page_id
      t.timestamps
    end
  end

  def self.down
    drop_table :page_contents
  end
end
