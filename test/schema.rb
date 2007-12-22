
ActiveRecord::Schema.define :version => 0 do

  say_with_time "Creating SQLite3 on memory database" do

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
      t.text :description
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

  end

end
