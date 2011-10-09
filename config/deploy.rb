# ssh options
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "passenger@pedpluspower.s3sol.com")]
# ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "s3sol.pem")]

# bundler bootstrap
require 'bundler/capistrano'

# main details
set :application, "pedplus"
role :web, "pedpluspower.s3sol.com"
role :app, "pedpluspower.s3sol.com"
role :db,  "pedpluspower.s3sol.com", :primary => true

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
    # Restart the resque workers
    run "cd #{current_release} && bundle exec rake environment queue:restart_workers"
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

# GOD
# see http://www.tatvartha.com/2010/09/monitoring-rails-processes-apache-passenger-delayed_job-using-god-and-capistrano-2/
namespace :god do
  task :start, :roles => :app do
    god_config_file = "#{shared_path}/config/pedplus.god"
    sudo "service god start"
    sudo "god --log-level debug -c #{god_config_file}"
  end
  task :stop, :roles => :app do
    sudo "service god stop"
  end
  task :restart, :roles => :app do
    sudo "service god stop"
    god_config_file = "#{shared_path}/config/pedplus.god"
    sudo "service god start"
    sudo "god --log-level debug -c #{god_config_file}"
  end
  task :status, :roles => :app do
    sudo "service god status"
  end
  task :log, :roles => :app do
    sudo "tail -f /var/log/messages"
  end
  task :deploy_config, :roles => :app do
    location = fetch(:template_dir, "config/deploy") + '/pedplus.god.erb'
    template = File.read(location)
    config = ERB.new(template)
    run "mkdir -p #{shared_path}/config" 
    put config.result(binding), "#{shared_path}/config/pedplus.god"

    god_config_file = "#{shared_path}/config/pedplus.god"
    sudo "god load #{god_config_file}"
  end
  task :symlink_config, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/pedplus.god #{current_release}/config/pedplus.god" 
  end
  task :redeploy, :roles => :app do
    god.deploy_config
    god.load_config
  end
end

after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"


after "deploy:setup", "god:deploy_config"
after "deploy:finalize_update", "god:symlink_config"
before "deploy:restart", "god:restart"

before "deploy:restart", "bundle:install"
before "deploy:migrate", "bundle:install"

after "deploy:migrations", "deploy:cleanup"