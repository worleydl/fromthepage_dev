# == Schema Information
#
# Table name: sc_collections
#
#  id            :integer          not null, primary key
#  label         :string(255)
#  version       :string(255)      default("2")
#  created_at    :datetime
#  updated_at    :datetime
#  at_id         :string(255)
#  collection_id :integer
#  parent_id     :integer
#
# Indexes
#
#  index_sc_collections_on_collection_id  (collection_id)
#
class ScCollection < ApplicationRecord
  belongs_to :collection, optional: true
  has_many :sc_manifests

  attr_accessor :service
  attr_accessor :v3_hash

# TEST_COLLECTION = <<EOI
# {"@context":"http://iiif.io/api/presentation/2/context.json","@id":"http://manifests.ydc2.yale.edu/manifest","@type":"sc:Collection","manifests":[{"@id":"http://manifests.ydc2.yale.edu/manifest/DecretumMagistriGratiani","@type":"sc:Manifest","label":"Friedberg, ed., Decretum magistri Gratiani "},{"@id":"http://manifests.ydc2.yale.edu/manifest/YCBAB1981_25_278","@type":"sc:Manifest","label":"A Lady and Her Two Children (B1981.25.278)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Admont23","@type":"sc:Manifest","label":"Aa, Admont, Benediktinerstift Admont Bibliothek & Museum, Admont MS 23"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Admont43","@type":"sc:Manifest","label":"Aa, Admont, Benediktinerstift Admont Bibliothek & Museum, Admont MS 43"},{"@id":"http://manifests.ydc2.yale.edu/manifest/MSPeniarth393DMultispectral","@type":"sc:Manifest","label":"Aberystwyth, National Library of Wales, MS Peniarth 393D Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Ripoll078","@type":"sc:Manifest","label":"Bc, Barcelona, Archivo de la Corona de Aragon, Ripoll 78"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CambridgeTrinityCollegeMSB_15_17","@type":"sc:Manifest","label":"Cambridge University, Trinity College MS B.15.17"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CambridgeTrinityCollegeMSB_15_17Multispectral","@type":"sc:Manifest","label":"Cambridge University, Trinity College MS B.15.17 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CambridgeDd_4_24","@type":"sc:Manifest","label":"Cambridge, Cambridge University Library, Cambridge Dd.4.24"},{"@id":"http://manifests.ydc2.yale.edu/manifest/kk13","@type":"sc:Manifest","label":"Cambridge, Cambridge University Library, Cambridge MS Kk.1.3"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CambridgeTrinityCollegeMSR_3_2","@type":"sc:Manifest","label":"Cambridge, Trinity College MS R.3.2"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CambridgeTrinityCollegeMSR_3_2Multispectral","@type":"sc:Manifest","label":"Cambridge, Trinity College MS R.3.2 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/HLSMS64","@type":"sc:Manifest","label":"Cd, Cambridge, Mass., Harvard Law School Library MS 64"},{"@id":"http://manifests.ydc2.yale.edu/manifest/FlorenceBibliotecaNazionaleCentraleConv_Soppr_A_1_402Fd_","@type":"sc:Manifest","label":"Fd, Florence, Biblioteca Nazionale Centrale, Conv. Soppr. A. 1. 402"},{"@id":"http://manifests.ydc2.yale.edu/manifest/B1981_25_403","@type":"sc:Manifest","label":"Grey Brydges, fifth Baron Chandos, of Sudeley Castle, Gloucestershire (YCBA B1981.25.403)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/B1992_8_1","@type":"sc:Manifest","label":"Jerusalem: The Emanation of The Giant Albion, Bentley Copy E (B1992.8.1)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CologneErzbischflicheDiozesanundDombibliothek127Ka","@type":"sc:Manifest","label":"Ka, Cologne, Erzbischfliche Diozesan- und Dombibliothek MS 127"},{"@id":"http://manifests.ydc2.yale.edu/manifest/CologneErzbischflicheDiozesanundDombibliothek128Kb","@type":"sc:Manifest","label":"Kb, Cologne, Erzbischfliche Diozesan- und Dombibliothek MS 128"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Buddha","@type":"sc:Manifest","label":"Buddha"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BLHarleyMS7334","@type":"sc:Manifest","label":"London, British Library, Harley MS 7334"},{"@id":"http://manifests.ydc2.yale.edu/manifest/GettyLudwigIX8","@type":"sc:Manifest","label":"Los Angeles, J. Paul Getty Museum, MS Ludwig IX 8"},{"@id":"http://manifests.ydc2.yale.edu/manifest/MSPeniarth392DHengwrtMultispectral","@type":"sc:Manifest","label":"MS Peniarth 392D Hengwrt Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Merthyrfragment","@type":"sc:Manifest","label":"Aberystwyth, National Library of Wales, Merthyr fragment"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS10","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 10"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS109","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 109"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS310","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 310"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS360","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 360"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS525","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 525"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS748","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 748"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BeineckeMS748_5","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Beinecke MS 748.5"},{"@id":"http://manifests.ydc2.yale.edu/manifest/MarstonMS22","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Marston MS 22"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Osborna44","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Osborn a44"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Osbornfa1","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Osborn fa1"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Osbornfa1v2","@type":"sc:Manifest","label":"New Haven, Beinecke Rare Book and Manuscript Library, Yale University, Osborn fa1"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Osbornfa1Multispectral","@type":"sc:Manifest","label":"Osborn fa1 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley113","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 113"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley294","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 294"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley758","@type":"sc:Manifest","label":"Bodleian MS Bodley 758"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley850","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 850"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Bodley861","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 861"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley861","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 861"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSBodley902","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MSBodley 902"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Bodley920","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 920"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSDouce18","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Douce 18"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Douce231","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Douce 231"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_GoughLiturg_19","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Gough Liturg. 19"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSGoughLiturg_3","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Gough Liturg. 3"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Lat_Liturg_f_21","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Lat. Liturg. f. 21"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Lat_liturg_f_2","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Lat. liturg. f. 2"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_LaudMisc_188","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Laud Misc. 188"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMSLaudMisc_204","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Laud Misc. 204"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Laud_Lat_4","@type":"sc:Manifest","label":"Bodleian MS. Laud. Lat. 4"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Laud_Lat_4Multispectral","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Laud. Lat. 4 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Lat_liturg_e_17","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS liturg. e. 17"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Auct_D_inf_2_11","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS. Auct. D. inf. 2. 11"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BodleianMS_Bodley716","@type":"sc:Manifest","label":"Oxford, Bodleian Libraries, University of Oxford, MS Bodley 716"},{"@id":"http://manifests.ydc2.yale.edu/manifest/OxfordCorpusChristiMS198","@type":"sc:Manifest","label":"Oxford, Corpus Christi College, University of Oxford, Corpus Christi MS 198"},{"@id":"http://manifests.ydc2.yale.edu/manifest/OxfordCorpusChristiMS198Multispectral","@type":"sc:Manifest","label":"Oxford, Corpus Christi College, University of Oxford, Corpus Christi MS 198 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BnFLatin38841","@type":"sc:Manifest","label":"Pf, Paris, Biblioth\u00e8que nationale de France, MS Latin 3884 (1)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BnFLatin38842","@type":"sc:Manifest","label":"Pf, Paris, Biblioth\u00e8que nationale de France, MS Latin 3884 (2)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BNFLatin3895","@type":"sc:Manifest","label":"Py, Paris, Biblioth\u00e8que nationale de France, MS lat. 3895 "},{"@id":"http://manifests.ydc2.yale.edu/manifest/HuntingtonMSEL26C9Multispectral","@type":"sc:Manifest","label":"San Marino, Huntington Library, MS EL 26 C9 Multispectral"},{"@id":"http://manifests.ydc2.yale.edu/manifest/HuntingtonMSEL26C9","@type":"sc:Manifest","label":"San Marino, Huntington Library, MS EL 26.C.9"},{"@id":"http://manifests.ydc2.yale.edu/manifest/Scroll","@type":"sc:Manifest","label":"Scroll"},{"@id":"http://manifests.ydc2.yale.edu/manifest/SanktGallenStiftsbibliothek673Sg","@type":"sc:Manifest","label":"Sg, Sankt Gallen, Stiftsbibliothek 673"},{"@id":"http://manifests.ydc2.yale.edu/manifest/B1981_25_404","@type":"sc:Manifest","label":"Sir William Pope (B1981.25.404)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/BlakeCopyL","@type":"sc:Manifest","label":"Songs of Innocence and of Experience, Copy L"},{"@id":"http://manifests.ydc2.yale.edu/manifest/B1992_8_11","@type":"sc:Manifest","label":"The Poems of Thomas Gray (B1992.8.13)"},{"@id":"http://manifests.ydc2.yale.edu/manifest/WGSS120","@type":"sc:Manifest","label":"WGSS_120"}]}
#
# EOI
  UCD = 'https://data.ucd.ie/api/img/collections/'
  UNIVERSE = 'https://raw.githubusercontent.com/ryanfb/iiif-universe/gh-pages/iiif-universe.json'
  def self.universe
    # fetch the universe doc
    connection = URI.open(UNIVERSE)
    universe_json = connection.read
    service = IIIF::Service.parse(universe_json)

    # loop through collections
    universe_collections = []
    service.collections.each do |json_collection|
      # create stub collections
      sc_collection = ScCollection.new
      sc_collection.at_id = json_collection['@id']
      sc_collection.label = json_collection.label

      universe_collections << sc_collection
    end

    #manually add UCD
    universe_collections << ScCollection.new(:at_id => UCD, :label => 'University College Dublin')

    universe_collections
  end

  def self.collection_for_at_id(at_id)
    connection = URI.open(at_id)
    collection_json = connection.read
    #collection_json = TEST_COLLECTION
    service = IIIF::Service.parse(collection_json)
    sc_collection = ScCollection.where(:at_id => at_id).first || ScCollection.new
    sc_collection.at_id = service['@id']
    sc_collection.label = service.label || sc_collection.at_id
    sc_collection.service = service
    sc_collection.save!

    sc_collection
  end

  def self.collection_for_v3_hash(v3)
    at_id = v3['id']
    sc_collection = ScCollection.where(:at_id => at_id).first || ScCollection.new
    sc_collection.at_id = at_id
    sc_collection.label = ScManifest.pluck_language_value(v3['label'])
    sc_collection.version='3'
    if v3.is_a? String
      sc_collection.v3_hash = JSON.parse(v3)
    else
      sc_collection.v3_hash = v3
    end
    sc_collection.save!

    sc_collection
  end

  def thumbnail
    if self.v3?
      thumb = v3_hash['thumbnail']
      thumb = thumb[first] if thumb
      thumb = thumb['id'] if thumb
      thumb
    else
      self.service.thumbnail
    end
  end

  def description
    if v3?
      summary = v3_hash['summary']
      if summary.blank?
        ""
      else
        ScManifest.pluck_language_value(v3_hash['summary'])
      end
    else
      service.description
    end

  end

  def collections
    if self.v3?
      v3_hash['items'].select { |item| item['type'] == 'Collection' }
    else
      self.service.collections
    end
  end

  def manifests
    if self.v3?
      v3_hash['items'].select { |item| item['type'] == 'Manifest' }
    else
      self.service.manifests
    end
  end




  def v3?
    self.version == '3'
  end


end
