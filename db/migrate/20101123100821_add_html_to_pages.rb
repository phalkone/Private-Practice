class AddHtmlToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :html, :boolean
  end

  def self.down
    remove_column :pages, :html
  end
end
