ActiveRecord::Schema.define do

  create_table :typus_users, :force => true do |t|
    t.string :email, :first_name, :last_name
    t.string :salt, :crypted_password
    t.boolean :status, :default => false
    t.boolean :admin, :default => false
    t.timestamps
  end

  create_table :tags, :force => true do |t|
    t.string :name
  end

  create_table :users, :force => true do |t|
    t.string :first_name, :last_name, :email
  end

  create_table :posts, :force => true do |t|
    t.string :title
    t.text :body
    t.boolean :status
    t.timestamps
    t.integer :user_id
  end

  create_table :categories, :force => true, :force => true do |t|
    t.string :name
    t.string :permalink
    t.text :description
    t.integer :position
  end

  create_table :categories_posts, :force => true, :id => false do |t|
     t.column :category_id, :integer
     t.column :post_id, :integer
  end

  create_table :comments, :force => true do |t|
    t.string :email, :name
    t.text :body
    t.integer :post_id
  end

  create_table :schema_info, :force => true do |t|
    t.string :version
  end

end