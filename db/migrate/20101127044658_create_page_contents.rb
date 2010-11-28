class CreatePageContents < ActiveRecord::Migration
  def self.up
    create_table :page_contents do |t|
      t.string :title
      t.text :body
      t.string :locale
      t.boolean :html
      t.integer :page_id

      t.timestamps
    end
    
    remove_column :pages, :title
    remove_column :pages, :body
    remove_column :pages, :locale
    remove_column :pages, :html
  end

  def self.down
    add_column :pages, :title, :string
    add_column :pages, :html, :boolean
    add_column :pages, :body, :text
    add_column :pages, :locale, :string
    drop_table :page_contents
  end
end
