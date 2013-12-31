# Git Ignore
file '.gitignore', <<-GITIGNORE, :force => true
.bundle
.DS_Store
.sass-cache/*
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

  # Download bootstrap.js
  if yes?("Do you want to use Bootstrap JS? Yes/No")
    inside('vendor/assets/javascripts/') do
      run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/js/bootstrap.js > bootstrap.js'
    end
  end

  git add: "."
  git commit: %Q{ -m 'bootstrap added' }
end


