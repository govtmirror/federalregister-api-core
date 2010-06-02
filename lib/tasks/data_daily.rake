namespace :data do
  task :daily => %w(
    data:daily:quick
    data:extract:regulationsdotgov_id
    
    data:cache:update:all
    tmp:cache:clear
    thinking_sphinx:index
    sitemap:refresh
  )
  
  namespace :daily do 
    task :quick => %w(
    content:entries:import
    data:import:bulkdata
    data:download:full_text
    
    content:section_highlights:clone
    content:entries:import:graphics
    
    data:extract:places
    )
  end
end