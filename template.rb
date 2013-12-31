# initialize repository
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# create databases
rake("db:create")

# implement active admin - Rails 4 only
if yes?("Do you want to use ActiveAdmin? -- Rails 4 branch --")
  gem 'activeadmin', github: 'gregbell/active_admin'
  email_address = ask("Give me an email address: ")
  password = ask("Give me a password: ")
  generate(active_admin:install)
  rake("db:migrate")
  git add: "."
  git commit: %Q{ -m 'active_admin added' }
end
