# Indexes resources loaded into Fedora from CITI.
class CitiIndexer < ActiveFedora::IndexingService
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc["read_access_group_ssim"] = ["group", "registered"]
      solr_doc[Solrizer.solr_name("aic_type", :facetable)] = object.class.to_s
      solr_doc[Solrizer.solr_name("status", :symbol)] = [object.status.pref_label] if object.status
    end
  end
end
