namespace :typus do
  
  desc "Initialize plugin"
  task :init  do
    system "script/generate model user first_name:string last_name:string email:string hashed_password:string status:boolean is_admin:boolean created_at:datetime"
    Rake::Task["db:migrate"].invoke
    system "rm app/models/user.rb"
    User.create(:first_name => 'First Name', :last_name => 'Last Name', :is_admin => true, :status => true, :email => 'admin@foo.com', :password => "typuscms", :password_confirmation => "typuscms")
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/config/typus.yml #{RAILS_ROOT}/config"
  end

  desc "Install CSS and images"
  task :setup do
    system "mkdir #{RAILS_ROOT}/public/stylesheets/typus"
    system "mkdir #{RAILS_ROOT}/public/images/typus"
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/stylesheets/* #{RAILS_ROOT}/public/stylesheets/typus"
    system "cp #{RAILS_ROOT}/vendor/plugins/typus/public/images/* #{RAILS_ROOT}/public/images/typus"
  end

end
