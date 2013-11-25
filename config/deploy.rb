# This is a set of sample deployment recipes for deploying via Capistrano.
# One of the recipes (deploy:symlink_nginx) assumes you have an nginx configuration
# file at config/nginx.conf. You can make this easily from the provided sample
# nginx configuration file.
#
# For help deploying via Capistrano, see this thread:
# http://meta.discourse.org/t/deploy-discourse-to-an-ubuntu-vps-using-capistrano/6353

require 'bundler/capistrano'
require 'sidekiq/capistrano'

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/thin"
load "config/recipes/postgresql"
load "config/recipes/redis"
load "config/recipes/rbenv"
load "config/recipes/check"

# Repo Settings
# You should change this to your fork of discourse
set :repository, 'git@github.com:pablojimeno/discourse.git'
set :deploy_via, :remote_cache
set :branch, fetch(:branch, 'manual')
set :scm, :git
ssh_options[:forward_agent] = true

# General Settings
set :deploy_type, :deploy
default_run_options[:pty] = true

# Server Settings
set :user, 'deployer'
set :use_sudo, false
set :rails_env, :production

server '162.243.97.83', :web, :app, :db, primary: true

# Application Settings
set :application, 'discourse'
set :deploy_to, "/home/#{user}/apps/#{application}"

# Perform an initial bundle
after "deploy:setup" do
  run "cd #{current_path} && bundle install"
end

namespace :deploy do
  desc "Moves and replaces the secret-token if missing in shared directory"
  task :symlink_secret, :roles => :app, :except => { :no_release => true } do 
    filename       = 'secret_token.rb'
    release_secret = "#{release_path}/config/initializers/#{filename}"
    shared_secret  = "#{shared_path}/config/#{filename}"
    
    if capture("[ -f #{shared_secret} ] || echo missing").start_with?('missing')
      run "cd #{current_path} && bundle exec rake secret", :env => { :RAILS_ENV => rails_env }
      run "mkdir -p #{shared_path}/config; mv #{release_secret} #{shared_secret}"
    end
    
    # symlink secret token
    run "ln -nfs #{shared_secret} #{release_secret}"
  end
end
  
# after "deploy:update", "deploy:symlink_secret"