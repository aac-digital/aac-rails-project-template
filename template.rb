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
end

# implement active admin - Rails 4 only
if yes?("Do you want to use ActiveAdmin? Yes/No")
  gem 'activeadmin', github: 'gregbell/active_admin'
  run 'bundle install'

  #email_address = ask("Give me a valid email address: ")
  #password = ask("Give me a password - min 6 char: ")
  generate 'active_admin:install'
  rake("db:migrate")
  #AdminUser.create!(:email => email_address, :password => password, :password_confirmation => password)

  git add: "."
  git commit: %Q{ -m 'active_admin added' }
end

# Download bootstrap.css
if yes?("Do you want to use Bootstrap CSS? Yes/No")
  inside('vendor/assets/stylesheets/') do
    run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/css/bootstrap.css > bootstrap.css'
  end
end

# Download bootstrap.js
if yes?("Do you want to use Bootstrap JS? Yes/No")
  inside('vendor/assets/javascripts/') do
    run 'curl -s https://raw.github.com/twbs/bootstrap/master/dist/js/bootstrap.js > bootstrap.js'
  end
end
