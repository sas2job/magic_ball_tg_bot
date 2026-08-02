namespace :deploy do
  desc 'Install gems with Bundler'
  task :bundle_install do
    on roles(:app) do
      within release_path do
        execute :bundle, :install
      end
    end
  end
end

after 'deploy:updated', 'deploy:bundle_install'
