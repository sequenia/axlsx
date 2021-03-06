module Axlsx

  # A comment is the text data for a comment
  class Comment

    include Axlsx::OptionsParser
    include Axlsx::Accessors

    # Creates a new comment object
    # @param [Comments] comments The comment collection this comment belongs to
    # @param [Hash] options
    # @option [String] author the author of the comment
    # @option [String] text The text for the comment
    # @option [String] ref The refence (e.g. 'A3' where this comment will be anchored.
    # @option [Boolean] visible This controls the visiblity of the associated vml_shape.
    def initialize(comments, options={}, pic_path = "")
      raise ArgumentError, "A comment needs a parent comments object" unless comments.is_a?(Comments)
      @visible = true
      @comments = comments
      @text = ""
      @author = ""
      parse_options options
      unless pic_path == ""
        @bg_picture = Pic.new(self, {image_src: pic_path, noSelect: true, noMove: true})
      end
      yield self if block_given?
    end

    string_attr_accessor :text, :author
    boolean_attr_accessor :visible

    attr_accessor :width
    attr_accessor :height
    attr_accessor :width_in_columns, :height_in_rows,
                  :left_offset, :top_offset, :right_offset, :bottom_offset

    # The owning Comments object
    # @return [Comments]
    attr_reader :comments

    # The string based cell position reference (e.g. 'A1') that determines the positioning of this comment
    # @return [String|Cell]
    attr_reader :ref

    attr_accessor :bg_picture

    # TODO
    # r (Rich Text Run)
    # rPh (Phonetic Text Run)
    # phoneticPr (Phonetic Properties)

    # The vml shape that will render this comment
    # @return [VmlShape]
    def vml_shape
      @vml_shape ||= initialize_vml_shape
    end

    # The index of this author in a unique sorted list of all authors in
    # the comment.
    # @return [Integer]
    def author_index
      @comments.authors.index(author)
    end

    # @see ref
    def ref=(v)
      Axlsx::DataTypeValidator.validate :comment_ref, [String, Cell], v
      @ref = v if v.is_a?(String)
      @ref = v.r if v.is_a?(Cell)
    end

    # serialize the object
    # @param [String] str
    # @return [String]
    def to_xml_string(str = "")
      author = @comments.authors[author_index]
      str << ('<comment ref="' << ref << '" authorId="' << author_index.to_s << '">')
      str << '<text>'
      unless author.to_s == ""
        str << '<r><rPr><b/><color indexed="81"/></rPr>'
        str << ("<t>" << author.to_s<< ":\n</t></r>")
      end
      str << '<r>'
      str << '<rPr><color indexed="81"/></rPr>'
      unless  text.to_s == ""
        str << ('<t>' << text << '</t>')
      else
        str << ('<t xml:space="preserve">' << '</t>')
      end
      str << '</r></text>'
      str << '</comment>'
    end

    private

    # initialize the vml shape based on this comment's ref/position in the worksheet.
    # by default, all columns are 5 columns wide and 5 rows high
    def initialize_vml_shape
      pos = Axlsx::name_to_indices(ref)
      @vml_shape = VmlShape.new(:row => pos[1], :column => pos[0], :visible => @visible, :fill_image => @bg_picture) do |vml|
        vml.left_column = vml.column
        vml.right_column = vml.column + (self.width_in_columns || 2)
        vml.top_row = vml.row
        vml.bottom_row = vml.row + (self.height_in_rows || 4)

        vml.left_offset = self.left_offset if self.left_offset.present?
        vml.top_offset = self.top_offset if self.top_offset.present?
        vml.right_offset = self.right_offset if self.right_offset.present?
        vml.bottom_offset = self.bottom_offset if self.bottom_offset.present?

        vml.fill_image = @bg_picture
        vml.width = self.width
        vml.height = self.height
      end
    end
  end
end
