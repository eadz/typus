class ActionController::Routing::RouteSet
  alias draw_without_admin draw
  def draw_with_admin
    draw_without_admin do |map|
      prefix = 'admin'
      map.typus_login "#{prefix}/login", :controller => 'sessions', :action => 'create'
      map.typus_logout "#{prefix}/logout", :controller => 'sessions', :action => 'destroy'
      map.password_recover "#{prefix}/password_recover", :controller => 'sessions', :action => 'password_recover'
      map.with_options :controller => 'typus' do |i|
        i.admin "#{prefix}", :action => 'index'
        i.connect "#{prefix}/-/:action/:id", :action => 'index', :requirements => { :model => nil }
        i.connect "#{prefix}/asset/*path", :action => 'asset'
        i.connect "#{prefix}/:model/:action", :action => 'index', :requirements => { :action => /[^0-9].*/, :id => nil }
        i.connect "#{prefix}/:model/:id/:action", :action => 'edit', :requirements => { :id => /\d+/ }
      end
      yield map
    end
  end
  alias draw draw_with_admin
end
