class AddSplitToAppointments < ActiveRecord::Migration
  def self.up
    add_column :appointments, :split, :integer
  end

  def self.down
    remove_column :appointments, :split
  end
end
