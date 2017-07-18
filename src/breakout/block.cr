module Breakout
  struct Block
    include SF::Drawable
    property destroyed : Bool = false
    property element : SF::RectangleShape

    def initialize(index : Int32, size : SF::Vector2 | Tuple = SF::Vector2.new(0, 0))
      @element = SF::RectangleShape.new(size)
      @element.position = {MARGIN_SIDE + (index % BLOCK_COUNT_X) * @element.size.x, MARGIN_TOP + (index % BLOCK_COUNT_Y) * @element.size.y}
      @element.fill_color = SF::Color::Red
      @element.outline_color = SF::Color::Blue
      @element.outline_thickness = 1
    end

    def draw(target : SF::RenderTarget, states : SF::RenderStates)
      target.draw(@element)
    end
  end
end
