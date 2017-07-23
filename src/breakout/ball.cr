module Breakout
  class Ball < SF::CircleShape
    getter direction : UInt64 = 315_u64 # 225_u64


    private def collision_vertical
      if @direction == 45_u64
        @direction += 90_u64
      elsif @direction == 135_u64
        @direction -= 90_u64
      elsif @direction == 225_u64
        @direction += 90_u64
      elsif @direction == 315_u64
        @direction -= 90_u64
      end
    end

    private def collision_horizontal
      if @direction == 45_u64
        @direction += 270_u64
      elsif @direction == 135_u64
        @direction += 90_u64
      elsif @direction == 225_u64
        @direction -= 90_u64
      elsif @direction == 315_u64
        @direction -= 270_u64
      end
    end

    def collision(vertical : Bool)
      if vertical
        collision_vertical
      else
        collision_horizontal
      end
    end
  end
end
