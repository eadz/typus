Typus
=====

As Django Admin, Typus is designed for a single activity:

> Trusted users editing structured content.

Once installed and configured you can login at http://application.tld/admin/

Note: Typus doesn't try to be all the thing to all the people.

## Installing

You can view the available tasks running

    rake typus

### Step 1: Install extra plugins

    rake typus:dependencies

This task will install for you:

- Gem `paginator`
- `paperclip` File upload
- `acts_as_list`
- `acts_as_tree`

### Step 2: Copy stylesheets to your public/ folder.

    rake typus:assets

### Step 3: Create an initial configuration file at `config/typus.yml`

    rake typus:configure

### Step 4: Create the needed tables on the db by running.

    script/generate typus_migration
    rake db:migrate
    rake typus:seed email='youremail@yourdomain.com' RAILS_ENV=production

### Step 5: Start your application

Start your application and go to http://application.tld/admin/

## Plugin Configuration Options

You can overwriting the following settings:

    Typus::Configuration.options[:app_name] = "Your app name"
    Typus::Configuration.options[:app_description] = "App Details"
    Typus::Configuration.options[:per_page] = "20"
    Typus::Configuration.options[:form_rows] = "20"
    Typus::Configuration.options[:form_columns] = "20"
    Typus::Configuration.options[:color] = "20"
    Typus::Configuration.options[:app_logo] = "url/to/application/logo"
    Typus::Configuration.options[:app_logo_height] = "400px"
    Typus::Configuration.options[:app_logo_width] = "400px"

Place this settings in a initializer at <code>config/initializers/typus.rb</code>.

## Configuration file options

If the configuration file is broken you'll see a +typus.yml+ text on the admin interface.

### Typus Fields

    fields:
      list: name, created_at, category_id, status
      form: name, body, created_at, status
      relationship: name, category_id

NOTE: Upload files only works if you follow Paperclip naming conventions.

### External Forms

    relationships:
      has_and_belongs_to_many: users
      has_many: projects

### Filters

    filters: status, author_id, created_at

### Order

Adding minus (-) sign before the attribute will make the order DESC.

    order_by: -attribute1, attribute2

### Searches

    search: attribute1, attribute2

### Want more actions?

    actions:
      list: notify_all
      form: notify

These actions will only be available on the context +list+ and +form+ of Typus.

You'll have to create controllers that inherit from TypusController

    class Typus::NewslettersController < TypusController
    
      ##
      # Action to deliver emails ...
      def deliver
        ...
        redirect_to :back
      end
    
    end

For feedback you can use the flash method.

- `flash[:notice]` just some feedback.
- `flash[:error]` when there's something wront.
- `flash[:success]` when the action successfully finished.

### Applications, modules and submodules

To group modules into an application use `application`.

    application: CMS

Each module has submodules grouped using `module`.

    module: Article

Example: (E-Commerce Application)

    Product:
      application: ECommerce
    Client:
      application: ECommerce
    Category:
      module: Product
    Option Type:
      module: Product

Example: (Blog)

    Post:
      application: Blog
    Category:
      application: Blog
    Tag:
      module: Post

## Custom Views

You can add your custom views to match your application requirements. Views 
you can customize.

- `index.html.erb`
- `edit.html.erb`

Example:

You need a custom view on the Articles listing. Under `app/view/typus/articles`
add the file `index.html.erb` and Typus default listing will be overrided.

## Customize Interface

You can customize the interface by placing on `views/typus` the following files.

### Dashboard

- `_dashboard_sidebar.html.erb`
- `_dashboard_top.html.erb`
- `_dashboard_bottom.html.erb`

### Models

- `MODEL/_index_top.html.erb`
- `MODEL/_index_bottom.html.erb`
- `MODEL/_new_top.html.erb`
- `MODEL/_new_bottom.html.erb`
- `MODEL/_new_bottom.html.erb`
- `MODEL/_new_sidebar.html.erb`
- `MODEL/_edit_top.html.erb`
- `MODEL/_edit_bottom.html.erb`
- `MODEL/_edit_bottom.html.erb`
- `MODEL/_edit_sidebar.html.erb`

## Acknowledgments

- Isaac Feliu - http://railslab.net/
- Jaime Iniesta - http://railes.net/
- supercoco9, sd and hydrus (sort_by)
- Laia Gargallo - http://azotacalles.net/
- Xavier Noria (fxn) - http://www.hashref.com/

## Author, contact & bugs

You can contact me at <fesplugas@intraducibles.net>

BROWSE SOURCE on GitHub: http://github.com/fesplugas/typus

Copyright (c) 2007-2008 Francesc Esplugas Marti, released under the MIT license