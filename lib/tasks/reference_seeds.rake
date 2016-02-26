namespace :db do
  namespace :seed do
    task reference_seeds: :environment do
      filename = File.join(Rails.root, 'db', 'reference-seeds.rb')
      load(filename) if File.exist?(filename)
    end
  end
end
