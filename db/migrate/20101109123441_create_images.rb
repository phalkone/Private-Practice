class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.binary :picture
      t.string :name
      t.string :filetype
      t.string :description

      t.timestamps
    end
    add_index :images, :name, :unique => true
  end

  def self.down
    drop_table :images
  end
end
