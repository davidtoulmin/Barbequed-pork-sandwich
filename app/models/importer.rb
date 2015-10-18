module Importer

  # Return a list of importers to scrape
  def importers
    [TheAgeVicImporter, NewsAUImporter, GuardianImporter, NYTImporter, TheAgePoliticsImporter, TheBBCImporter, SBSImporter, HeraldSunImporter, SydneyMorningHeraldImporter]
  end
end
