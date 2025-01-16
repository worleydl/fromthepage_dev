require 'elastic_util'

# This concern allows for simple hookup of models to be persisted into Elasticsearch.
#
# While it handles most updates/deletes there is potential for drift when collection
# level permissions change.  It's recommended to do a rolling index or setup an
# external indexer that handles all needed changes from relationships.
#
module ElasticDelta
  extend ActiveSupport::Concern

  # Setup elastic hooks for models
  included do
    if ELASTIC_ENABLED
      after_save :es_update
      after_destroy :es_delete
    end
  end

  private

  # Map model types to collection names
  def get_index_for_type(type)
    if type.is_a?(Collection)
      return 'ftp_collection'
    elsif type.is_a?(DocumentSet)
      return 'ftp_collection' # DocSets intentionally put into collection for now
    elsif type.is_a?(Page)
      return 'ftp_page'
    elsif type.is_a?(User)
      return 'ftp_user'
    elsif type.is_a?(Work)
      return 'ftp_work'
    end
  end

  def es_update
    index = get_index_for_type(self)
    doc_id = self.id
    body = self.as_indexed_json().except(:_id)

    perm_key = nil
    if self.is_a?(Collection)
      perm_key = :restricted
    elsif self.is_a?(DocumentSet)
      perm_key = :is_public
    end

    # Update permissions timestamp on dirty permissions fields
    if perm_key
      if saved_changes.key?(perm_key)
        body[:permissions_updated] = Time.now.utc.to_i
      end
    end

    # Hack for storing docsets alongside collections
    if self.is_a?(DocumentSet)
      doc_id = "docset-#{doc_id}"
    end

    # Must use index instead of update since we don't store data in index currently
    ElasticUtil.get_client().index(
      index: index,
      id: doc_id,
      body: body
    )
  end

  def es_delete
    index = get_index_for_type(self)
    doc_id = self.id

    # Hack for storing docsets alongside collections
    if self.is_a?(DocumentSet)
      doc_id = "docset-#{doc_id}"
    end

    ElasticUtil.get_client().delete(
      index: index,
      id: doc_id
    )
  end

end
