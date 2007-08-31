namespace :royale do
  
  namespace :scm do
  
    namespace :svn do
      
      desc "Add pending files to Subversion"
      task :add do
        system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
      end
      
      desc "Ignore log & tmp files"
      task :ignores do
        system "svn remove log/*"
        system "svn commit -m 'removing log files'"
        system "svn propset svn:ignore '*.log' log/"
        system "svn update log/"
        system "svn commit -m 'Ignoring all files in /log/ ending in .log'"
        system "svn remove tmp/*"
        system "svn propset svn:ignore '*' tmp/"
        system "svn update tmp/"
        system "svn commit -m 'ignore tmp/ content from now'"
      end
      
    end
    
    namespace :hg do
      
      desc "Ignore log & tmp files"
      task :ignores do
        
      end
      
      desc 'Update code from Mercurial'
      task :up do
        sh %{hg pull && hg up}
      end
      
    end
    
  end

end
