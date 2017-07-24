module Breakout
  class Ball < SF::CircleShape
    getter direction : UInt64 = 315_u64 # 225_u64


    private def collision_vertical
      if 0_u64 <= @direction < 90_u64
        @direction += (90_u64 - @direction) * 2
      elsif 90_u64 <= @direction < 180_u64
        @direction -= (@direction - 90_u64) * 2
      elsif 180_u64 <= @direction < 270_u64
        @direction += (90_u64 - (@direction - 180_u64)) * 2
      elsif 270_u64 <= @direction <= 360_u64
        @direction -= (90_u64 - (360_u64 - @direction)) * 2
      end
    end

    private def collision_horizontal
      if 0_u64 <= @direction < 90_u64
        @direction += 360_u64 - @direction * 2
      elsif 90_u64 <= @direction < 180_u64
        @direction += 180_u64 - (@direction - 90_u64) * 2
      elsif 180_u64 <= @direction < 270_u64
        @direction -= (@direction - 180_u64) * 2
      elsif 270_u64 <= @direction <= 360_u64
        @direction = 360_u64 - @direction
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
