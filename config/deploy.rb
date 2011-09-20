# ssh options
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "passenger@virginia.s3sol.com")]

# bundler bootstrap
require 'bundler/capistrano'

# main details
set :application, "pedplus"
role :web, "virginia.s3sol.com"
role :app, "virginia.s3sol.com"
role :db,  "virginia.s3sol.com", :primary => true

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false
set :deploy_to, "/var/www/rails/pedplus"
set :deploy_via, :remote_cache
set :user, "passenger"
set :use_sudo, false

# repo details
set :scm, :git
set :scm_username, "passenger"
set :repository, "gitosis@git.s3sol.com:pedplus.git"
set :branch, "master"
# set :git_enable_submodules, 1
set :git_shallow_clone, 1

set :keep_releases, 5

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

namespace :db do
  task :setup, :except => { :no_release => true } do
    location = fetch(:template_dir, "config/deploy") + '/database.yml.erb'
    template = File.read(location)

    config = ERB.new(template)

    run "mkdir -p #{shared_path}/config" 
    put config.result(binding), "#{shared_path}/config/database.yml"
  end

  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
  end
end

after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"

before "deploy:restart", "bundle:install"
before "deploy:migrate", "bundle:install"

after "deploy:migrations", "deploy:cleanup"