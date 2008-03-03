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
        i.connect "#{prefix}/:model/:action", :requirements => { :action => /index|new|create/ }, :action => 'index'
        i.connect "#{prefix}/:model/:id/:action", :requirements => { :action => /edit|update|destroy|position|status|relate|unrelate/, :id => /\d+/ }, :action => 'edit'
      end
      map.connect "#{prefix}/:model/:action", :controller => 'typus_extras'
      map.connect "#{prefix}/:model/:id/:action", :controller => 'typus_extras'
      yield map
    end
  end

  alias draw draw_with_admin

end