Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = (ENV["WORKER_POLL_INTERVAL"] || 1.0).to_f
end
