# Git Ignore
file '.gitignore', <<-GITIGNORE, :force => true
.bundle
.DS_Store
.sass-cache/*
.ruby-version
.powrc
.rvmrc
*.swp
*.swo
**/.DS_STORE
binstubs/*
bundler_stubs/*
config/database.yml
coverage/*
db/*.sqlite3
db/structure.sql
log/*.log
log/*.pid
public/system/*
public/stylesheets/compiled/*
public/assets/*
public/uploads/*
tmp/*
GITIGNORE

inside('config/') do
  run 'curl -s https://gist.github.com/harisadam/8200106/raw/8857a9da5f51ad27e1d32a23336cbd89a8d82ec5/database.example.yml > database.example.yml'
end

# create databases
rake("db:create")

# add some basic gem
gem 'haml'
gem 'sass'
gem 'carrierwave'
gem 'mini_magick'
gem 'cocoon'
gem_group :development do
  gem 'powder'
  gem 'better_errors'
  gem 'quiet_assets'
end

# basic layout
inside('app/views/layouts') do
  run 'rm application.html.erb'
  file 'application.html.haml', <<-TEMPLATE
!!!
%html{lang: "en"}
  %head
    %meta{charset: "utf-8"}/
    %title Rename
    %meta{content: "Fill with your description", name: "description"}/
    %meta{content: "Acts as Consultancy", name: "author"}/
    %meta{'http-equiv' => 'X-UA-Compatible', :content => 'chrome=1'}/
    = stylesheet_link_tag    :application, media: :all
    = javascript_include_tag '//cdnjs.cloudflare.com/ajax/libs/modernizr/2.5.3/modernizr.min.js'
    = csrf_meta_tags
    / HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries
    /[if lt IE 9]
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    / Le fav and touch icons
  %body
    /[if lt IE 7]
      <p class="chromeframe">You are using an outdated browser. <a href="http://browsehappy.com/">Upgrade your browser today</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to better experience this site.</p>
    = yield
    = javascript_include_tag :application
TEMPLATE
end

# application.css
inside('app/assets/stylesheets') do
  run 'rm application.css'
  file 'style.css.scss.erb'
  file 'application.css.scss.erb', <<-FILE
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require style
 */
FILE
end

inside('app/assets/javascripts') do
  run 'rm application.js'
  file 'app.js'
  file 'application.js', <<-FILE
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require app
//= require_tree .
FILE
end

insert_into_file "app/assets/javascripts/application.js", "//= require cocoon\n", :after => "require jquery_ujs\n"

# create fonts dir
run('mkdir app/assets/fonts')
FileUtils.touch('app/assets/fonts/.gitkeep')

# create readme.md
run 'rm README.rdoc'
file 'README.md', <<-README
# #{app_name}
README

# initialize repository
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# Test helper gems
if yes?("Do you want to include test helper gems? Yes/No")
  gem_group :test do
    gem 'factory_girl_rails'
    gem 'mocha'
    gem 'shoulda'
  end

  gem_group :development do
    gem 'guard-minitest'
    gem 'capybara'
  end

  run 'bundle install'
  git add: "."
  git commit: %Q{ -m 'test helper gems added' }
end

# implement active admin - Rails 4 only
if yes?("Do you want to use ActiveAdmin? Yes/No")
  # install
  gem 'activeadmin', github: 'gregbell/active_admin'
  run 'bundle install'
  generate 'active_admin:install'

  # create user
  email_address = ask("Give me a valid email address: ")
  password = ask("Give me a password - min 6 char: ")
  comment_lines Dir.glob("db/migrate/*_create_admin_users.rb")[0], /admin@example.com/
  insert_into_file Dir.glob("db/migrate/*_create_admin_users.rb")[0], "AdminUser.create!(:email => '#{email_address}', :password => '#{password}', :password_confirmation => '#{password}')", :after => "# Create a default user\n"
  rake("db:migrate")

  git add: "."
  git commit: %Q{ -m 'active_admin added' }
end

if yes?("Do you want to use Heroku? Yes/No")
  gem 'rails_12factor', group: :production
  run 'heroku create --region eu'

  git add: "."
  git commit: %Q{ -m 'heroku config added' }
end

# Download bootstrap.css
if yes?("Do you want to use Bootstrap CSS? Yes/No")
  inside('vendor/assets/stylesheets/') do
    run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/css/bootstrap.css > bootstrap.css'
  end
  insert_into_file "app/assets/stylesheets/application.css.scss.erb", " *= require bootstrap\n", :after => "require_self\n"

  # Download bootstrap.js
  if yes?("Do you want to use Bootstrap JS? Yes/No")
    inside('vendor/assets/javascripts/') do
      run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/js/bootstrap.js > bootstrap.js'
    end
    insert_into_file "app/assets/javascripts/application.js", "//= require bootstrap\n", :after => "require jquery_ujs\n"
  end

  git add: "."
  git commit: %Q{ -m 'bootstrap added' }
end

if yes?("Do you want to use Capistrano v2.x Yes/No")
  gem 'capistrano', '~> 2.15'
  run 'bundle install'
  run('bundle exec capify .')

  git add: "."
  git commit: %Q{ -m 'capistrano added' }
end

# create pow link
if yes?("Do you want to create a POW link?")
  run('bundle exec powder link')
end

