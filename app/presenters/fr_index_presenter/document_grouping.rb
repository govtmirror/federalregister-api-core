class FrIndexPresenter
  class DocumentGrouping
    attr_reader :parent, :header, :entries, :fr_index_subject
    delegate :last_completed_issue,
      :granule_class,
      :entry_ids_for_year,
      :to => :parent

    def initialize(parent, header, entries, fr_index_subject = nil)
      @parent = parent
      @header = header
      @entries = entries
      @fr_index_subject = fr_index_subject
    end

    def entry_count
      @entries.count
    end

    def comments_open?
      entries.any?(&:comments_open?)
    end

    def has_comments?
      entries.any?{|e| e.comment_count > 0}
    end

    def significant?
      entries.any?(&:significant?)
    end

    def needs_attention_count
      needs_attention? ? 1 : 0
    end

    def needs_attention?
      old_entry_count == 0 && unmodified?
    end

    def oldest_issue_needing_attention
      entries.map(&:publication_date).min if needs_attention?
    end

    def identifier
      "#{granule_class}_#{Digest::MD5.hexdigest(header)}"
    end

    def top_level_header
      top_level? ? header : fr_index_subject
    end

    def top_level?
      fr_index_subject.blank?
    end

    def header_attribute
      'fr_index_doc'
    end

    private

    def old_entry_count
      date = last_completed_issue
      if date
        count = entries.select{|e| e.publication_date <= date}.size
        if count > 0
          return count
        else
          Entry.find_as_array([<<-SQL, entry_ids_for_year, last_completed_issue, entries.first.fr_index_subject, entries.first.fr_index_doc]).first.to_i
            SELECT COUNT(*)
            FROM entries
            LEFT OUTER JOIN public_inspection_documents
              ON public_inspection_documents.entry_id = entries.id
            WHERE entries.id IN (?)
              AND entries.publication_date <= ?
              AND IFNULL(IFNULL(fr_index_subject, IFNULL(public_inspection_documents.toc_subject, entries.toc_subject)),'_null_') = IFNULL(?, '_null_')
              AND IFNULL(fr_index_doc, IFNULL(IFNULL(public_inspection_documents.toc_doc, entries.toc_doc), entries.title)) = ?
          SQL
        end
      else
        0
      end
    end

    def unmodified?
      entries.none?(&:modified?)
    end
  end
end
