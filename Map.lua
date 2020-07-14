Map = Class{}

TILE_BRICK = 3
TILE_EMPTY = 30

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/tiles.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    
    --Filling the map with empty tiles
    for y = 1, self.mapHeight / 2 do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- Starts halfway down the map, populates with bricks
    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK)
        end
    end
end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y-1) * self.mapWidth + x]
end

function Map:update(dt)

end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x-1) * self.tileWidth, (y-1) * self.tileHeight)
        end
    end
end