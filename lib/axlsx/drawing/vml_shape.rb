module Axlsx

  # A VmlShape is used to position and render a comment.
  class VmlShape

    include Axlsx::OptionsParser
    include Axlsx::Accessors

    # Creates a new VmlShape
    # @option options [Integer] row
    # @option options [Integer] column
    # @option options [Integer] left_column
    # @option options [Integer] left_offset
    # @option options [Integer] top_row
    # @option options [Integer] top_offset
    # @option options [Integer] right_column
    # @option options [Integer] right_offset
    # @option options [Integer] bottom_row
    # @option options [Integer] bottom_offset
    def initialize(options={})
      @row = @column = @left_column = @top_row = @right_column = @bottom_row = 0
      @left_offset = 15
      @top_offset = 2
      @right_offset = 50
      @bottom_offset = 5
      @visible = true
      @fill_image = nil
      @id = (0...8).map{65.+(rand(25)).chr}.join
      parse_options options
      yield self if block_given?
    end

    unsigned_int_attr_accessor :row, :column, :left_column, :left_offset, :top_row, :top_offset,
                               :right_column, :right_offset, :bottom_row, :bottom_offset

    boolean_attr_accessor :visible
    attr_accessor :width
    attr_accessor :height

    attr_accessor :fill_image

    # serialize the shape to a string
    # @param [String] str
    # @return [String]
    
    def to_xml_string(str ='')
        styles = []
        styles << "visibility:#{@visible == true ? 'visible' : 'hidden'}"

        str << "<v:shape id=\"#{@id}\" type=\"#_x0000_t202\"" 
        if @fill_image.nil?
          str << "fillcolor=\"#ffffa1 [80]\""
        end
        str << " o:insetmode=\"auto\" style=\"#{styles.join(';')}\">"
        if @fill_image.nil?
          str << ""  
        else
          str << "<v:fill o:relid=\"#{@fill_image.relationship.Id}\" color2=\"#ffffa1\" recolor=\"t\" rotate=\"t\" type=\"frame\"/>"
        end
        str << "<v:shadow on=\"t\" obscured=\"t\"/>"
        str << "<v:path o:connecttype=\"none\"/>"
        str << "<v:textbox style=\"mso-fit-text-with-word-wrap:t\">"
        str << "<div style=\"text-align:left\"></div>"
        str << "</v:textbox>"
        str << "<x:ClientData ObjectType=\"Note\">"
        str << "<x:MoveWithCells/>"
        str << "<x:SizeWithCells/>"
        str << "<x:Anchor>#{left_column}, #{left_offset}, #{top_row}, #{top_offset}, #{right_column}, #{right_offset}, #{bottom_row}, #{bottom_offset}</x:Anchor>"
        str << "<x:AutoFill>False</x:AutoFill>"
        str << "<x:Row>#{row}</x:Row>"
        str << "<x:Column>#{column}</x:Column>"
        if @visible == true
          str << "<x:Visible/>"
        end
        str << "</x:ClientData>"
        str << "</v:shape>"
    end
  end
end
