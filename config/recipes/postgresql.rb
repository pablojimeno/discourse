set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }

namespace :pg do
  desc "Install PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y install postgresql-9.1 postgresql-contrib-9.1 libpq-dev libxml2-dev libxslt-dev make g++"
  end
  after "deploy:install", "pg:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "pg:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "pg:setup"

  desc "Seed your database with the initial production image. Note that the production image assumes an empty, unmigrated database."
  task :first_seed, roles: :db do
    run "cd #{current_path} && psql -d discourse_production < pg_dumps/production-image.sql"
  end
  # after "deploy:setup", "pg:first_seed"

  desc "Drop if database already exists."
  task :drop_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "drop database #{postgresql_database};"}
    run %Q{#{sudo} -u postgres psql -c "drop user #{postgresql_user};"}
  end

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "pg:symlink"

  # Migrate the database with each deployment
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  after  'deploy:cold', 'deploy:migrate'
  
  desc "tail production log files" 
  task :tail_logs, :roles => :app do
    trap("INT") { puts 'Interupted'; exit 0; }
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err
    end
  end
end