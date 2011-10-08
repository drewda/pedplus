require "resque/tasks"

# load up the entire Rails stack
task "resque:setup" => :environment

task "resque:restart_workers" => :environment do
  pids = Array.new

  Resque.workers.each do |worker|
    pids << worker.to_s.split(/:/).second
  end

  if pids.size > 0
    system("kill -QUIT #{pids.join(' ')}")
  end

  system("rm /var/run/god/resque-1.8.0*.pid")
end