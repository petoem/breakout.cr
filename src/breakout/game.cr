require "./settings.cr"
require "./player.cr"
require "./ball.cr"
require "./block.cr"

module Breakout
  class Game
    include SF::Drawable
    getter game_over : Bool = false
    getter running : Bool = false

    def initialize
      # Load Font
      @font = SF::Font.from_file("./resources/font/xeliard-font/Xeliard.ttf")
      # Load Textures
      @texture_ball = SF::Texture.from_file("./resources/image/ball.png", SF.int_rect(0, 0, 256, 256))
      @texture_ball.smooth = true
      @texture_bricks = Array(SF::Texture).new(4) { |index| SF::Texture.from_file("./resources/image/brick_flat/#{index + 1}.jpg", SF.int_rect(0, 0, 100, 30)) }
      # Game Texts
      @text_start = SF::Text.new("Press space to start!", @font, 50)
      @text_start.color = SF::Color::White
      @text_start.origin = {@text_start.global_bounds.width/2, @text_start.global_bounds.height/2}
      @text_start.position = {WINDOW_SIZE_X/2, WINDOW_SIZE_Y/2}
      @text_game_over = SF::Text.new("Game Over!", @font, 60)
      @text_game_over.color = SF::Color::White
      @text_game_over.origin = {@text_game_over.global_bounds.width/2, @text_game_over.global_bounds.height/2}
      @text_game_over.position = {WINDOW_SIZE_X/2, WINDOW_SIZE_Y/2}
      # Player
      @player = Player.new(SF.vector2f(PLAYER_SIZE_X, PLAYER_SIZE_Y))
      @player.position = {(WINDOW_SIZE_X - PLAYER_SIZE_X) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y}
      @player.fill_color = SF::Color.new(128, 128, 128)
      # Blocks
      @blocks = Array(Block).new(30) { |index| Block.new(index, @texture_bricks, SF.vector2f(BLOCK_SIZE_X, BLOCK_SIZE_Y)) }
      # Ball
      @ball = Ball.new BALL_SIZE
      @ball.fill_color = SF::Color::White
      @ball.position = {(WINDOW_SIZE_X - BALL_SIZE * 2) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y - BALL_SIZE * 2}
      @ball.set_texture(@texture_ball)
    end

    def start
      reset_player
      @running = true
      @game_over = false
    end

    def game_over
      @running = false
      @game_over = true
    end

    def reset_player
      @player.position = {(WINDOW_SIZE_X - PLAYER_SIZE_X) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y}
      @ball.position = {(WINDOW_SIZE_X - BALL_SIZE * 2) / 2, WINDOW_SIZE_Y - MARGIN_BOTTOM - PLAYER_SIZE_Y - BALL_SIZE * 2}
    end

    def update(elapsed : SF::Time)
      return if !@running || @game_over

      # Player
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

      # Ball
      (elapsed.as_seconds * BALL_VELOCITY).to_i32.times do
        # Collision bottom
        if @ball.position.y >= WINDOW_SIZE_Y - BALL_SIZE*2
          game_over
          break
        end
        # Collison player
        player_collision = @ball.global_bounds.intersects?(@player.global_bounds)
        if player_collision
          if player_collision.width/(BALL_SIZE*2) < player_collision.height/(BALL_SIZE*2)
            @ball.collision true
          else
            @ball.collision false
          end
        end
        # Collison wall
        @ball.collision true if @ball.position.x <= 0 || @ball.position.x >= WINDOW_SIZE_X - BALL_SIZE*2
        @ball.collision false if @ball.position.y <= 0
        # Collision block
        block_died = false
        @blocks.map! do |block|
          cbox = @ball.global_bounds.intersects?(block.element.global_bounds)
          if cbox && !block.destroyed && !block_died
            if cbox.width/(BALL_SIZE*2) > cbox.height/(BALL_SIZE*2)
              @ball.collision false
            else
              @ball.collision true
            end
            block.destroyed = true
            block_died = true
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
      target.draw @text_start unless @running || @game_over
      target.draw @text_game_over if @game_over
    end
  end
end
