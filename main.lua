WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--Close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()
    math.randomseed(os.time())
    map = Map()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false, resizable = true, vsync = true})

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    map:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(108/255, 140/255, 1, 1)
    --love.graphics.print("Hello world!")
    map:render()
    push:apply('end')
end