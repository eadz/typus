class CreateTypusUsers < ActiveRecord::Migration

  def self.up

    create_table :typus_users do |t|
      t.string :email, :salt, :crypted_password
      t.string :first_name, :last_name
      t.boolean :status, :default => false
      t.boolean :admin, :default => false
      t.timestamps
    end

    create_table :typus_roles do |t|
      t.string :name, :email
      t.string :first_name, :last_name
      t.boolean :is_superuser, :default => false
      t.boolean :can_create_rol, :default => false
      t.boolean :can_login, :default => false
      t.string :salt, :crypted_password
      t.timestamp :valid_until
    end

  end

  def self.down
    drop_table :typus_users
    drop_table :typus_roles
  end

end