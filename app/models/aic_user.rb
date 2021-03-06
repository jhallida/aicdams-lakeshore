class AICUser < CitiResource
  class << self
    def aic_type
      super << AICType.User
    end

    # @param [String] nick complete match on nick
    # @return [AICUser, nil]
    def find_by_nick(nick)
      where(Solrizer.solr_name("nick", :symbol).to_sym => nick).first
    end

    # @param [String] query partial matches on nick, last name, or user name
    # @return [Array<Hash>, nil]
    def search(query)
      q = Blacklight.default_index.connection.get('select', params: user_query(query))
      response = Blacklight::Solr::Response.new(q, user_query(query))
      response.documents.map { |d| json_result(d) }
    end

    private

      def user_query(query)
        {
          q: "#{query}~",
          qt: "search",
          df: "nick_tesim",
          qf: "nick_tesim given_name_tesim family_name_tesim",
          fl: "nick_tesim, pref_label_tesim"
        }
      end

      def json_result(doc)
        {
          id: doc.fetch("nick_tesim").first,
          text: CitiResourcePresenter.new(find_by_nick(doc.fetch("nick_tesim"))).display_name
        }
      end
  end

  type aic_type

  property :given_name, predicate: ::RDF::Vocab::FOAF.givenName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :family_name, predicate: ::RDF::Vocab::FOAF.familyName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :nick, predicate: ::RDF::Vocab::FOAF.nick, multiple: false do |index|
    index.as :symbol, :stored_searchable
  end

  property :mbox, predicate: ::RDF::Vocab::FOAF.mbox, multiple: false do |index|
    index.as :symbol
  end
end
