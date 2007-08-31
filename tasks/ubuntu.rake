namespace :royale do
  
  namespace :ubuntu do
    
    desc "Install default Software"
    task :setup do
      sudo "apt-get update"
      sudo "apt-get upgrade -y"
      sudo "apt-get install build-essential -y"
      sudo "apt-get install manpages-dev autoconf automake libtool -y"
      sudo "apt-get install flex bison gcc-doc g++ -y"
      sudo "apt-get install curl -y"
      sudo "apt-get install wget -y"
      sudo "apt-get install subversion -y"
      sudo "apt-get install ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8 libreadline-ruby1.8 libruby1.8 irb libzlib-ruby libopenssl-ruby -y"
      sudo "apt-get install libfcgi-dev libfcgi-ruby1.8 -y"
      sudo "apt-get install rails -y"
      sudo "apt-get install libsqlite3-0 libsqlite3-dev sqlite3 swig libsqlite3-ruby -y"
      sudo "apt-get install mysql-server libmysql-ruby libmysqlclient14-dev -y"
      sudo "apt-get install postfix -y"
    end
    
    desc "Install Rails"
    task :setup_rails do
      #curl -O http://rubyforge.iasi.roedu.net/files/rubygems/rubygems-0.9.0.tgz;
      #tar xvzf rubygems*;
      #cd rubygems*;
      #ruby setup.rb;
      #cd ..;
      #rm -r rubygems*;
      sudo "gem update --system"
      sudo "gem install -y --no-rdoc --no-ri rake"
      sudo "gem install -y --no-rdoc --no-ri rails --include-dependencies"
      sudo "gem install -y --no-rdoc --no-ri daemons"
      sudo "gem install -y --no-rdoc --no-ri gem_plugin"
      sudo "wget http://rubyforge.org/frs/download.php/3088/sqlite3-ruby-1.1.0.gem"
      sudo "gem install --no-rdoc --no-ri sqlite3-ruby-1.1.0.gem"
      sudo "rm sqlite3-ruby-1.1.0.gem"
      sudo "gem install --no-rdoc --no-ri -v 2.7 mysql"
    end
    
    desc "Upgrade software"
    task :update_and_upgrade do
      run "sudo apt-get update && sudo apt-get upgrade"
    end
    
  end
  
end