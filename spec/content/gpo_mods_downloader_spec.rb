require 'ruby-debug'
require 'spec_helper'

describe Content::GpoModsDownloader do

  describe ".create_diff" do
    include FileIoSpecHelperMethods

    let(:spec_current_mods_path)   { File.join('data','mods') }
    let(:spec_temporary_mods_path) { File.join('data','mods','tmp') }
    let(:spec_mods_archive_path)   { File.join('data','mods','archive') }

    before(:each) do
      @issue = Issue.create(:publication_date => "2099-01-01".to_date)
      @reprocessed_issue = ReprocessedIssue.new
      @reprocessed_issue.issue = @issue
      @reprocessed_issue.save
    end

    after(:each) do
      delete_file('data/mods/2099-01-01.xml')
      delete_file('data/mods/tmp/2099-01-01.xml')
    end

    it ".create_diff returns an empty string if the files are the same" do
      original_xml = "<XML></XML>"
      modified_xml = "<XML></XML>"
      create_file("data/mods/2099-01-01.xml", original_xml)
      create_file("data/mods/tmp/2099-01-01.xml", modified_xml)

      mods_downloader = Content::GpoModsDownloader.new(@reprocessed_issue.id)
      mods_downloader.create_diff
      @reprocessed_issue.reload.diff.should == ""
    end

    it ".create_diff returns a diff if the files are different" do
      original_xml = "<XML></XML>"
      modified_xml = "<XML>New Stuff</XML>"
      create_file("data/mods/2099-01-01.xml", original_xml)
      create_file("data/mods/tmp/2099-01-01.xml", modified_xml)

      mods_downloader = Content::GpoModsDownloader.new(@reprocessed_issue)
      mods_downloader.create_diff
      @reprocessed_issue.reload.diff.should be_present
    end

    it "removes lines included in the DIFF_PREFIXES TO REJECT constant" do
      original_xml = ""
      modified_xml = <<-XML
    <li class=\"del\"><del><span class=\"symbol\">-</span>&lt;identifier type=&quot;local&quot;&gt;P0b002ee18d3e<strong>0406</strong>&lt;/identifier&gt;</del></li>"
XML
      create_file("data/mods/2099-01-01.xml", original_xml)
      create_file("data/mods/tmp/2099-01-01.xml", modified_xml)

      mods_downloader = Content::GpoModsDownloader.new(@reprocessed_issue)
      mods_downloader.send(:html_diff).should == "<div class=\"diff\">\n  <ul>\n  </ul>\n</div>\n"
    end

    it "removes XML metadata lines." do
      original_xml = ""
      modified_xml = <<-XML
    <li class="del"><del><span class="symbol">-</span>&lt;mods xmlns=&quot;http://www.loc.gov/mods/v3&quot; xmlns:exslt=&quot;http://exslt.org/common&quot; xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xlink=&quot;http://www.w3.org/1999/xlink&quot; xsi:schemaLocation=&quot;http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd&quot; version=&quot;3.3&quot; ID=&quot;P0b002ee18d3e<strong>0406</strong>&quot;&gt;</del></li>
XML
      create_file("data/mods/2099-01-01.xml", original_xml)
      create_file("data/mods/tmp/2099-01-01.xml", modified_xml)

      FrDiff.new(
        File.join(spec_current_mods_path, "2099-01-01.xml"),
        File.join(spec_temporary_mods_path, "2099-01-01.xml"),
        :strings_to_reject => ["lt;mods xmlns"]
      ).
      html_diff.should == "<div class=\"diff\">\n  <ul>\n  </ul>\n</div>\n"
    end

    it "removes lines included in the strings_to_reject option" do
      original_xml = ""
      modified_xml = <<-XML
    <li class=\"del\"><del><span class=\"symbol\">-</span>&lt;identifier type=&quot;local&quot;&gt;P0b002ee18d3e<strong>0406</strong>&lt;/identifier&gt;</del></li>"
XML
      create_file("data/mods/2099-01-01.xml", original_xml)
      create_file("data/mods/tmp/2099-01-01.xml", modified_xml)
      FrDiff.new(
        File.join(spec_current_mods_path, "2099-01-01.xml"),
        File.join(spec_temporary_mods_path, "2099-01-01.xml"),
        :strings_to_reject => ["identifier type="]
      ).
      html_diff.should == "<div class=\"diff\">\n  <ul>\n  </ul>\n</div>\n"
    end


  end

end