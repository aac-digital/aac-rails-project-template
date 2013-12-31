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
bin/*
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

# initialize repository
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# create databases
rake("db:create")

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



# Test helper gems
if yes?("Do you want to include test helper gems? Yes/No")
  gem_group :test do
    gem 'factory_girl_rails'
    gem 'mocha'
    gem 'shoulda'
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
  run 'heroku create'

  git add: "."
  git commit: %Q{ -m 'heroku config added' }
end

# Download bootstrap.css
if yes?("Do you want to use Bootstrap CSS? Yes/No")
  inside('vendor/assets/stylesheets/') do
    run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/css/bootstrap.css > bootstrap.css'
  end
  insert_into_file "app/assets/stylesheets/application.css.scss.erb", "*= require bootstrap\n", :after => "require_self\n"

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


