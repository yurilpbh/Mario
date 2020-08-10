require 'Util'
require 'Player'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4
CLOUD_LEFT = 6
CLOUD_RIGHT = 7
BUSH_LEFT = 2
BUSH_RIGHT = 3
MUSHROOM_TOP = 10
MUSHROOM_DOWN = 11
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9
FLAG_TOP = 8
FLAG_MIDDLE = 12
FLAG_BOT = 16
FLAG_STOP_TOP = 14
FLAG_MOVE = 15
FLAG_STOP_BOT = 13

local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    --self.music = love.audio.newSource('sounds/music.wav', 'static')

    self.player = Player(self)

    self.camX = 0
    self.camY = -3
    
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    --Filling the map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    --Begin generating the terrain using vertical scan lines
    local x, pyramidHeight = 1, math.random(3,self.mapHeight / 2 - 6)
    local aux_PyramidY = self.mapHeight / 2 - 1
    while x < self.mapWidth do
        --2% chance to generate a cloud
        --Make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                --Choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        if pyramidHeight > 0 and x == self.mapWidth - (pyramidHeight + 5) then
            for aux_x = x, self.mapWidth do
                if(aux_x >= x and aux_x < x + pyramidHeight) then
                    for y = self.mapHeight / 2 - 1, aux_PyramidY, -1 do
                        self:setTile(aux_x, y, TILE_BRICK)
                    end
                    aux_PyramidY = aux_PyramidY - 1
                end
                if(aux_x == x + pyramidHeight + 2) then
                    for y = self.mapHeight / 2 - pyramidHeight, self.mapHeight / 2 - 1 do
                        if (y == self.mapHeight / 2 - pyramidHeight) then
                            self:setTile(aux_x, y, FLAG_TOP)
                            self:setTile(aux_x + 1, y, FLAG_STOP_TOP)
                        elseif (y == self.mapHeight / 2 - 1) then
                            self:setTile(aux_x, y, FLAG_BOT)
                        else
                            self:setTile(aux_x, y, FLAG_MIDDLE)
                        end
                    end
                end
                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(aux_x, y, TILE_BRICK)
                end
            end
            break
        --5% chance to generate a mushroom
        elseif math.random(20) == 1 then
            --Left side of pipe
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_DOWN)
            --Creates column of tiles going to bottom of mapHeight
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --Next vertical scan line
            x = x + 1
        --10% chance to generate bush, being sure to generate away from edge
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1
            --Place bush component and the column of bricks
            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
        --10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 then
            --Creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --Chance to create a block for Mario to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end
            x = x + 1
        else
            --Increment X so we skip two scanlines, createing a 2-tile gap
            x = x + 2
        end
    end

    music:setLooping(true)
    music:setVolume(0.10)
    music:play()
end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y-1) * self.mapWidth + x]
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_DOWN
    }

    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.player:update(dt)

    self.camX = math.max(0,
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x))) 
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x-1) * self.tileWidth, (y-1) * self.tileHeight)
        end
    end

    self.player:render()
end