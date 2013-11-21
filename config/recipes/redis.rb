namespace :redis do
  desc "Install Redis"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"

  desc "Setup Redis"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "redis.yml.erb", "#{shared_path}/config/redis.yml"
  end
  after "deploy:setup", "redis:setup"

  desc "Symlink the redis.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
  end
  after "deploy:finalize_update", "redis:symlink"
end