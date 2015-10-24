# This class searches the summary and title for proper nouns to tag on and add these to the list of tags

# David Toulmin 638541

module Tagger
  # Return a list of taggers to tag with
  def taggers
    [TagOpenCalais, TagAlchemy, TagSentimental, TagSummaryNouns, TagTitleNouns]
  end
end
