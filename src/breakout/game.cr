require "./settings.cr"
require "./player.cr"
require "./ball.cr"
require "./block.cr"

module Breakout
  class Game
    include SF::Drawable

    def initialize
      # Player
      @player = Player.new(SF.vector2f(PLAYER_SIZE_X, PLAYER_SIZE_Y))
      @player.position = {(WINDOW_SIZE_X - PLAYER_SIZE_X) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y}
      @player.fill_color = SF::Color.new(128, 128, 128)
      # Blocks
      @blocks = Array(Block).new(30) { |index| Block.new(index, SF.vector2f(BLOCK_SIZE_X, BLOCK_SIZE_Y)) }
      # Ball
      @ball = Ball.new BALL_SIZE
      @ball.fill_color = SF::Color.new(120, 0, 10)
      @ball.position = {(WINDOW_SIZE_X - BALL_SIZE * 2) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y - BALL_SIZE * 2}
    end

    def update(elapsed : SF::Time)
      (elapsed.as_seconds * PLAYER_SPEED).to_i32.times do
        # Move player
        @player.move(1, 0) if SF::Keyboard.key_pressed?(SF::Keyboard::Right) && @player.position.x <= WINDOW_SIZE_X - PLAYER_SIZE_X
        @player.move(-1, 0) if SF::Keyboard.key_pressed?(SF::Keyboard::Left) && @player.position.x > 0
        # Prevent ball and player overlap
        if @player.global_bounds.intersects?(@ball.global_bounds)
          @player.move(-1, 0) if SF::Keyboard.key_pressed?(SF::Keyboard::Right) && @player.position.x <= WINDOW_SIZE_X - PLAYER_SIZE_X
          @player.move(1, 0) if SF::Keyboard.key_pressed?(SF::Keyboard::Left) && @player.position.x > 0
        end
      end

      (elapsed.as_seconds * BALL_VELOCITY).to_i32.times do
        # Collison player
        @ball.direction = (@ball.direction + 90) % 360 if @ball.global_bounds.intersects?(@player.global_bounds)
        # Collison wall
        @ball.direction = (@ball.direction + 90) % 360 if @ball.position.x <= 0 || @ball.position.x >= WINDOW_SIZE_X - BALL_SIZE*2 || @ball.position.y >= WINDOW_SIZE_Y - BALL_SIZE*2 || @ball.position.y <= 0
        # Collision block
        @blocks.map! do |block|
          if @ball.global_bounds.intersects?(block.element.global_bounds) && !block.destroyed
            @ball.direction = (@ball.direction + 90) % 360 unless block.destroyed
            block.destroyed = true
          end
          block
        end
        @ball.move(Math.cos(@ball.direction * (Math::PI/180)), Math.sin(@ball.direction * (Math::PI/180)))
      end
    end

    def draw(target : SF::RenderTarget, states : SF::RenderStates)
      # Draw
      @blocks.each do |block|
        target.draw(block) unless block.destroyed
      end
      target.draw @ball
      target.draw @player
    end
  end
end
