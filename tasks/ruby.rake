namespace :royale do
  
  namespace :ruby do
    
    namespace :gems do
      
      desc "Cleanup old gems"
      task :cleanup do
        system "sudo gem cleanup"
      end
      
      desc "Install all needed gems."
      task :setup do
        system "sudo gem install capistrano --include-dependencies"
        system "sudo gem install mongrel --include-dependencies"
        system "sudo gem install termios --include-dependencies"
        system "sudo gem install aws-s3 --include-dependencies"
      end
      
      desc "Install update all gems"
      task :update do
        system "sudo gem update"
      end
      
    end
    
    namespace :rails do
      
      desc "Installs basic plugins"
      task :plugins do
        system "./script/plugin install http://svn.techno-weenie.net/projects/plugins/acts_as_versioned/"
        system "./script/plugin install http://svn.techno-weenie.net/projects/plugins/acts_as_paranoid/"
        system "./script/plugin install http://svn.techno-weenie.net/projects/plugins/acts_as_attachment/"
        system "./script/plugin install http://svn.rubyonrails.org/rails/plugins/acts_as_taggable/"
        system "./script/plugin install http://svn.rubyonrails.org/rails/plugins/exception_notification/"
        system "./script/plugin install http://svn.pragprog.com/Public/plugins/annotate_models/"
        system "./script/plugin install http://svn.rubyonrails.org/rails/plugins/scriptaculous_slider/"
        system "./script/plugin install http://svn.rubyonrails.org/rails/plugins/token_generator/"
        system "./script/plugin install http://svn.rubyonrails.org/rails/plugins/upload_progress/"
        system "./script/plugin install http://svn.techno-weenie.net/projects/plugins/restful_authentication/"
      end
      
    end
    
  end
  
end
