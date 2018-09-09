web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq --concurrency $WORKER_CONCURRENCY
release: bundle exec rake db:migrate
