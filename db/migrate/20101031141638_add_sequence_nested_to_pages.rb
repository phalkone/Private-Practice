class AddSequenceNestedToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :sequence, :decimal
    add_column :pages, :nested, :boolean
  end

  def self.down
    remove_column :pages, :nested
    remove_column :pages, :sequence
  end
end
