class ActionController::Routing::RouteSet

  alias draw_without_admin draw

  def draw_with_admin
    prefix = Typus::Configuration.options[:prefix]
    draw_without_admin do |map|
      map.with_options :controller => 'typus' do |i|
        i.typus_dashboard "#{prefix}", :action => 'dashboard'
        i.typus_login "#{prefix}/login", :action => 'login'
        i.typus_logout "#{prefix}/logout", :action => 'logout'
        i.typus_index "#{prefix}/:model", :action => 'index'
        i.connect "#{prefix}/:model/"
        i.connect "#{prefix}/:model/new", :action => 'new'
        i.connect "#{prefix}/:model/create", :action => 'create'
        i.connect "#{prefix}/:model/:id/position", :action => 'position'
        i.connect "#{prefix}/:model/:id/edit", :action => 'edit', :requirements => { :id => /\d+/ }
        i.connect "#{prefix}/:model/:id/update", :action => 'update', :requirements => { :id => /\d+/ }
        i.connect "#{prefix}/:model/:id/destroy", :action => 'destroy', :requirements => { :id => /\d+/ }
        i.connect "#{prefix}/:model/:id/relate", :action => 'relate', :requirements => { :id => /\d+/ }
        i.connect "#{prefix}/:model/:id/unrelate", :action => 'unrelate', :requirements => { :id => /\d+/ }
        i.connect "#{prefix}/:model/:id/status", :action => 'status', :requirements => { :id => /\d+/ }
      end
      yield map
    end
  end

  alias draw draw_with_admin

end