module ElasticUtil

  def self.get_client(enable_log = false)
    return Elasticsearch::Client.new(
      log: enable_log,
      cloud_id: ELASTIC_CLOUD_ID,
      api_key: ELASTIC_API_KEY
    )
  end

  def self.gen_bulk_action(index, body)
    bulk_action = {
      index: {
        _index: index,
        _id: body[:_id],
        data: body.except(:_id)
      }
    }

    return bulk_action
  end

  # Augments query by wrapping terms that look like identifiers in quotes
  def self.augment_query(query)
    if query.nil?
      return query
    end

    # Don't add quotes if query had existing ones
    if query.include?('"')
      return query
    end

    tokens = query.split
    augmented_tokens = []

    tokens.each do |t|
      if self.looks_like_id(t)
        augmented_tokens << '"' + t + '"'
      else
        augmented_tokens << t
      end
    end

    return augmented_tokens.join(' ')
  end

  # "Federated" query magic happens here
  def self.gen_query(user, query, types, query_config,
                     page, page_size, count_only = false)
    base_query = {
      query: {
        # This is what gets "generated"
        bool:  { must: { bool: { should: [] } }, filter:[] }
      },
      aggs: {
        # Counts per doc type
        type_counts: {
          terms: {
            field: "_index",
            size: 10 # Should never need more than 4
          }
        },
        # Total document count (sum of all types)
        total_doc_count: {
          sum_bucket: {
            buckets_path: "type_counts>_count",
          }
        }
      },
      # General weighting for multi-type search results
      # Note: Using wildcards as alias names don't carry thru to boosting results
      indices_boost: [
        { 'ftp_user*': 1000.0 }, # Can bring this down to "mix" users in results
        { 'ftp_collection*': 50.0 },
        { 'ftp_work*': 10.0 },
        { 'ftp_page*': 1.0 }
      ],
      from: (page - 1) * page_size,
      size: page_size
    }

    # Apply post filtering if configured
    if query_config.present?
      filter_mod = base_query[:query][:bool][:filter]
      case query_config[:type]
      when "org"
        filter_mod << { term: {owner_user_id: query_config[:org_id]} }
      when "collection"
        filter_mod << { term: {collection_id: query_config[:coll_id]} }
      when "docset"
        filter_mod << { term: {docset_id: query_config[:docset_id]} }
      when "work"
        filter_mod << { term: {work_id: query_config[:work_id]} }
      end
    end

    if count_only
      base_query[:from] = 0
      base_query[:size] = 0
    end

    # A mouthful, but we need a must wrapper of should clauses to support
    # post filtering on org
    to_mod = base_query[:query][:bool][:must][:bool][:should]

    # Wrap punctuated terms in quotes to avoid heavy recall
    precise_query = self.augment_query(query)

    # Build out query based on active types
    active_types = []
    if types.include?("collection")
      to_mod << Collection.es_match_query(precise_query, user)
      active_types << "ftp_collection"
    end

    if types.include?("page")
      to_mod << Page.es_match_query(precise_query, user)
      active_types << "ftp_page"
    end
    
    if types.include?("user")
      to_mod << User.es_match_query(precise_query)
      active_types << "ftp_user"
    end

    if types.include?("work")
      to_mod << Work.es_match_query(precise_query, user)
      active_types << "ftp_work"
    end

    return {
      query_body: base_query,
      indexes: active_types.join(",")
    }
  end

  # Elastic only gives us back doc types and ID's, need to convert those to objects
  # that rails knows how to work with
  def self.inflate_response(es_resp)
    collections = []
    docsets = []
    pages = []
    users = []
    works = []

    hits = es_resp['hits']['hits']
    doc_types = es_resp['aggregations']['type_counts']['buckets']
    total_count = es_resp['aggregations']['total_doc_count']['value']

    # Load up individual types from response
    collection_ids = hits
      .select { |x| x['_index'].include?('ftp_collection') && !x['_source']['is_docset'] }
      .map { |x| x['_id'] }

    docset_ids = hits
      .select { |x| x['_index'].include?('ftp_collection') && x['_source']['is_docset'] }
      .map { |x| x['_id'][7..-1] } # Need to drop prefix specializer for lookup

    page_ids = hits.select { |x| x['_index'].include?( 'ftp_page') }
      .map { |x| x['_id'] }

    user_ids = hits.select { |x| x['_index'].include?('ftp_user') }
      .map { |x| x['_id'] }

    work_ids = hits.select { |x| x['_index'].include?('ftp_work') }
      .map { |x| x['_id'] }

    collections = Collection.where(id: collection_ids)
    docsets = DocumentSet.where(id: docset_ids)
    pages = Page.where(id: page_ids)
    users = User.where(id: user_ids)
    works = Work.where(id: work_ids)

    # TODO: Handle IDs missing from database (deleted/unsynced)?
    inflated = []
    hits.each do |hit|
      if hit['_index'].include?('ftp_collection')
        if hit['_source']['is_docset']
          inflated << docsets.find { |x| x[:id].to_s == hit['_id'][7..-1] }
        else
          inflated << collections.find { |x| x[:id].to_s == hit['_id'] }
        end
      elsif hit['_index'].include?('ftp_page')
        inflated << pages.find { |x| x[:id].to_s == hit['_id'] }
      elsif hit['_index'].include?('ftp_user')
        inflated << users.find { |x| x[:id].to_s == hit['_id'] }
      elsif hit['_index'].include?('ftp_work')
        inflated << works.find { |x| x[:id].to_s == hit['_id'] }
      end
    end

    # Make convenient lookup for counts per type
    type_counts = {}
    aliased_types = ['ftp_collection', 'ftp_page', 'ftp_user', 'ftp_work']
    doc_types.each do |bucket|
      # Convert actual index name back into alias
      key = ''
      aliased_types.each do |type|
        if bucket['key'].include?(type)
          key = type
          break
        end
      end

      type_counts[key.to_sym] = bucket['doc_count']
    end

    return {
      inflated: inflated,
      type_counts: type_counts,
      full_count: total_count, # Can be overriden by filtered searches
      filtered_count: total_count
    }
  end

  def self.looks_like_id(token)
    if token.nil?
      return false
    end

    if token.include?('"')
      return false
    end

    # We say something looks like an ID if:
    # - Any punctuation is included (-._)
    if token.match?(/[.\-_]/)
      return true
    end

    return false
  end

  def self.reindex(model, index_name)
    client = self.get_client()

    # Allow simulatenous indexing requests
    pool_size= 2
    pool = WorkerPool.new(pool_size)
    pool.start

    model.find_in_batches(batch_size: 1000) do |batch|
      bulk_body = []
      batch.each do |item|
        item_body = item.as_indexed_json()

        # Skip errors
        if item_body.key?(:indexing_error)
          next
        end

        bulk_body.push(
          ElasticUtil.gen_bulk_action(index_name, item_body)
        )
      end

      # Don't overload pending tasks
      while pool.pending > pool_size * 2
        sleep(1)
      end

      # Execute requests in new thread, it takes more time to prep the the next batch
      pool.schedule do
        begin
          client.bulk(body: bulk_body, refresh: false)
        rescue => e
          puts "Error with threaded bulk request"
        end
      end
    end

    # Finish remaining tasks and shutdown
    pool.shutdown()

    client.indices.refresh(index: index_name)
  end

  # "Safe" methods wrap calls to elastic in basic exception handling
  def self.safe_delete(arguments = {})
    begin
      self.get_client().delete(arguments)
    rescue Exception
      # No-op
    end
  end

  def self.safe_delete_by_query(arguments = {})
    begin
      self.get_client().delete_by_query(arguments)
    rescue Exception
      # No-op
    end
  end

  def self.safe_index(arguments = {})
    begin
      self.get_client().index(arguments)
    rescue Exception
      # No-op
    end
  end

  # Returns mocked empty result set on exception
  def self.safe_search(arguments = {})
    begin
      resp = self.get_client()
        .search(arguments)

      if resp.key?('error')
        raise 'General elastic error'
      end

      return resp
    rescue Exception
      return {
        'hits' => {
          'total' => {
            'value' => 0,
            'relation' => 'eq'
          },
          'hits' => []
        },
        'aggregations' => {
          'type_counts' => {
            'buckets' => []
          },
          'total_doc_count' => {
            'value' => 0
          }
        }
      }
    end
  end

  # Helper threading pool to execute indexing requests in parallel
  class WorkerPool
    def initialize(size)
      @size = size
      @queue = Queue.new
      @threads = []
      @shutdown = false
    end

    def start
      @size.times do
        @threads << Thread.new do
          until @shutdown && @queue.size == 0
            task = @queue.pop(true) rescue nil
            task&.call

            if @queue.size == 0
              sleep(1)
            end
          end
        end
      end
    end

    def pending
      return @queue.size
    end

    def schedule(&task)
      @queue << task
    end

    def shutdown
      @shutdown = true
      @threads.each(&:join)
    end
  end

end
