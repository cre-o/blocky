module Blocky
  # A block of HTML content that can be rendered on one or multiple pages.
  class ContentBlock < ActiveRecord::Base
    # Validations
    validates :content_key, presence: true
    validates :content, presence: true, unless: :new_record?
    validates_presence_of :order
    validates_numericality_of :order, only_integer: true, greater_than_or_equal_to: 0
    # Callbacks
    before_save :encode_content

    # Returns the description of the content block if it exists.
    # The content key is used as a fallback if there is no description.
    def display_name
      description.blank? ? content_key : description
    end

  private

    # Force encoding of the content to UTF-8 before saving.
    def encode_content
      html = content.to_s.strip.force_encoding("utf-8")
      self.content = "\n" + (html.blank? ? "<p><br/></p>" : html) + "\n"
    end
  end
end
