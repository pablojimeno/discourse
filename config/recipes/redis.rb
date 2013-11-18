namespace :redis do
  desc "Install Redis"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"
end