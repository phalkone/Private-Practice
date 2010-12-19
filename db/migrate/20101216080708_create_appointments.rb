class CreateAppointments < ActiveRecord::Migration
  def self.up
    create_table :appointments do |t|
      t.integer :doctor_id
      t.integer :patient_id
      t.datetime :begin
      t.datetime :end
      t.string :comment
      t.integer :recurrence
      t.boolean :completed

      t.timestamps
    end
    
    add_index :appointments, :doctor_id
    add_index :appointments, :patient_id
  end

  def self.down
    drop_table :appointments
  end
end
