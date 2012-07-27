require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, 'pedplus.s3sol.com' # The hostname to SSH to
set :deploy_to, '/var/www/rails/pedplus' # Path to deploy into
set :repository, 'git@github.com:s3sol/pedplus.git' # Git repo to clone from
set :user, 'passenger' # Username in the  server to SSH to (optional)

set :shared_paths, ['log']

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "touch #{deploy_to}/tmp/restart.txt"
    end
  end
end
