namespace :content do
  namespace :gpo_images do

    desc "Run the eps_import driver"
    task :import_eps => :environment do
      Content::ImportDriver::EpsImportDriver.new.perform
    end

    desc "Download GPO images and move them to S3."
    task :import_eps_raw_task => :environment do
      GpoImages::EpsImporter.run
    end

    desc "Run the convert_eps driver"
    task :convert_eps => :environment do
      Content::ImportDriver::FileImportDriver.new.perform
    end

    desc "Download the .eps images from S3, convert them, and upload them to FR app-specific S3 bucket."
    task :convert_eps_raw_task => :environment do
      GpoImages::FileImporter.run
    end

    desc "Run the process_daily_issue_images driver"
    task :process_daily_issue_images => :environment do
      Content::ImportDriver::DailyIssueImageProcessorDriver.new.perform
    end

    desc "Delete the date's redis keys and re-execute the eps_conversion process."
    task :force_convert_eps => :environment do
      GpoImages::FileImporter.force_eps_convert
      Content::ImportDriver::FileImportDriver.new.perform
    end

    desc "Scan through the most recent issue's XML--noting image usages and moving images to public buckets accordingly"
    task :process_daily_issue_images_raw_task => :environment do
      GpoImages::DailyIssueImageProcessor.perform
    end

  end
end