class ActionController::Routing::RouteSet

  alias draw_without_admin draw

  def draw_with_admin

    @prefix = TYPUS['prefix']

    draw_without_admin do |map|
      map.with_options :controller => 'typus' do |i|
        i.admin "#{@prefix}", :action => 'dashboard'
        i.connect "#{@prefix}/:model/:action", :action => 'index', :requirements => { :action => /[^0-9].*/, :id => nil }
        i.connect "#{@prefix}/:model/:id/:action", :action => 'edit', :requirements => { :id => /\d+/ }
      end
      yield map
    end
  end

  alias draw draw_with_admin

end