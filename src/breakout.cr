require "crsfml"
require "./breakout/*"

breakout_game = Breakout::Game.new

window = SF::RenderWindow.new(SF::VideoMode.new(Breakout::WINDOW_SIZE_X, Breakout::WINDOW_SIZE_Y), Breakout::NAME, settings: SF::ContextSettings.new(depth: 24, antialiasing: 8))
window.framerate_limit = 60
clock = SF::Clock.new

while window.open?
  while event = window.poll_event
    window.close if event.is_a?(SF::Event::Closed)
  end
  window.clear SF::Color::Black
  breakout_game.update clock.restart
  window.draw(breakout_game)
  window.display
end
