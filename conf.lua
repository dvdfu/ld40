local Constants = require 'src.Constants'

function love.conf(t)
    t.window.title = 'LD40'
    t.window.resizable = false
    t.window.vsync = true
    t.window.width = Constants.SCREEN_WIDTH
    t.window.height = Constants.SCREEN_HEIGHT
end
