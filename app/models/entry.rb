=begin Schema Information

 Table name: entries

  id                   :integer(4)      not null, primary key
  title                :text
  abstract             :text
  contact              :text
  dates                :text
  action               :text
  type                 :string(255)
  identifier           :string(255)
  link                 :string(255)
  genre                :string(255)
  part_name            :string(255)
  citation             :string(255)
  granule_class        :string(255)
  document_number      :string(255)
  toc_subject          :string(255)
  toc_doc              :string(255)
  length               :integer(4)
  start_page           :integer(4)
  end_page             :integer(4)
  publication_date     :date
  effective_date       :date
  created_at           :datetime
  updated_at           :datetime
  places_determined_at :datetime

=end Schema Information

class Entry < ActiveRecord::Base
  has_many :agency_assignments
  has_many :agencies, :through => :agency_assignments
  
  has_many :topic_assignments
  has_many :topics, :through => :topic_assignments
  
  has_many :url_references
  has_many :urls, :through => :url_references
  
  has_many :place_determinations
  has_many :places, :through => :place_determinations
  
  def month_year
    publication_date.to_formatted_s(:month_year)
  end
  
  def day
    publication_date.strftime('%d')
  end
end
