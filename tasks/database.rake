namespace :royale do
  
  namespace :database do
    
    desc "Create MySQL databases"
    task :setup do
      @dbs ||= YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/database.yml")).result)
      # Development
      if @dbs['development']['adapter'] == "mysql"
        system "mysqladmin -u #{@dbs['development']['username']} create #{@dbs['development']['database']}"
      elsif @dbs['development']['adapter'] == "postgresql"
        system "createdb #{@dbs['development']['database']}"
      end
      # Test
      if @dbs['test']['adapter'] == "mysql"
        system "mysqladmin -u #{@dbs['test']['username']} create #{@dbs['test']['database']}"
      elsif @dbs['test']['adapter'] == "postgresql"
        system "createdb #{@dbs['development']['database']}"
      end
      # Production
      if @dbs['production']['adapter'] == "mysql"
        run "mysqladmin -u #{@dbs['production']['username']} create #{@dbs['production']['database']}"
      elsif @dbs['development']['adapter'] == "postgresql"
        run "createdb #{@dbs['production']['database']}"
      end
    end
    
    desc "Create Snaphshot"
    task :snapshot do
      @dbs ||= YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/database.yml")).result)
      Dir.mkdir("#{RAILS_ROOT}/db/snapshots") unless FileTest.directory?("#{RAILS_ROOT}/db/snapshots")
      system "sqlite3 db/#{@dbs['development']['database']}.sqlite3 .dump > db/snapshots/#{timestamp}.dump"
    end
    
  end
  
end