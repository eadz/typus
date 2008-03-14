class CreateTypusUsers < ActiveRecord::Migration

  def self.up
    create_table :typus_users do |t|
      t.string :email, :hashed_password
      t.string :first_name, :last_name
      t.boolean :status, :default => false
      t.boolean :admin, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :typus_users
  end

end