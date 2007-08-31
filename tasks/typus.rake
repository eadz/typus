namespace :typus do
  
  desc "Initialize plugin"
  task :init  do
    system "script/generate model user first_name:string last_name:string email:string hashed_password:string status:boolean is_admin:boolean created_at:datetime"
    Rake::Task["db:migrate"].invoke
    # system "script/runner \"User.create(:first_name => 'First Name', :last_name => 'Last Name', :is_admin => true, :status => true, :email => 'admin@foo.com', :password => 'typus', :password_confirmation => 'typus')\""
    system "script/runner \"User.create(:first_name => 'First Name')\""
  end

  desc "Install CSS and images"
  task :setup do
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/stylesheets/* #{RAILS_ROOT}/public/stylesheets"
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/images/* #{RAILS_ROOT}/public/images"
  end

end
