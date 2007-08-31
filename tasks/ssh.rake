require File.join(File.dirname(__FILE__), 'royale.rb')

namespace :royale do
  
  namespace :ssh do
    
    desc "Create a key"
    task :create_key do
      system "ssh-keygen -t dsa"
    end
    
    desc "Upload key to server"
    task :upload_key do
      load_data
      system "scp ~/.ssh/id_dsa.pub #{@royale['ssh']['user']}@#{@royale['ssh']['server']}:/Users/#{@royale['ssh']['user']}/.ssh/authorized_keys"
    end
    
    desc "Connect to server"
    task :connect do
      load_data
      system "ssh #{@ssh['user']}@#{@ssh['server']}"
    end
    
  end
  
end
