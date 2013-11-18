set_default(:thin_user) { user }
set_default(:thin_pid) { "#{current_path}/tmp/pids/thin.pid" }
set_default(:thin_config) { "#{shared_path}/config/thin.yml" }
set_default(:thin_log) { "#{shared_path}/log/thin.log" }

namespace :thin do
  desc "Setup Thin initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "thin.yml.erb", thin_config

  end

  after "deploy:setup", "thin:setup"

  # Tasks to start/stop/restart thin
  desc 'Start thin servers'
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml start", :pty => false
  end

  desc 'Stop thin servers'
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec thin -C config/thin.yml stop"
  end

  desc 'Restart thin servers'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml restart"
  end
     
end