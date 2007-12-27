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
        i.connect "#{prefix}/:model/:action", :requirements => { :action => /[^0-9].*/, :id => nil }
        i.connect "#{prefix}/:model/:id/:action", :action => 'edit', :requirements => { :id => /\d+/ }
      end
      yield map
    end

  end

  alias draw draw_with_admin

end
