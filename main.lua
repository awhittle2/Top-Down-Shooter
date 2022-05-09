function love.load() -- Function to execute before the game loads
    sprites = {} -- Table to store sprites
    sprites.player = love.graphics.newImage('sprites/player.png') -- Player image
    sprites.bullet = love.graphics.newImage('sprites/bullet.png') -- Bullet image
    sprites.zombie = love.graphics.newImage('sprites/zombie.png') -- Zombie image
    sprites.background = love.graphics.newImage('sprites/background.png') -- Background image

    player = {} -- Table to store player data
    player.x = love.graphics.getWidth() / 2 -- Sets player's x to center
    player.y = love.graphics.getHeight() / 2 -- Set player's y to center
    player.speed = 180 -- 3 (speed we want at 60fps) * 60 (since dt updates every 1/60 seconds) = constant speed at constant time

    zombies = {}
end

function love.update(dt) -- Function to update the game loop
    if love.keyboard.isDown("d") then -- If the d key is pressed
        player.x = player.x + player.speed*dt -- Goes right at a constant speed per second
    end
    if love.keyboard.isDown("s") then -- If the s key is pressed
        player.y = player.y + player.speed*dt -- Goes down at a constant speed per second
    end
    if love.keyboard.isDown("a") then -- If the a key is pressed
        player.x = player.x - player.speed*dt -- Goes left at a constant speed per second
    end
    if love.keyboard.isDown("w") then -- If the w key is pressed
        player.y = player.y - player.speed*dt -- Goes up at a constant speed per second
    end
end

function love.draw() -- Function to render graphics to the screen
    love.graphics.draw(sprites.background, 0, 0) -- Puts in the background

    love.graphics.draw(sprites.player, player.x, player.y, faceMouse(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2) -- Draws the player at the player's position

    for i,z in ipairs(zombies) do -- Loops through all zombies in zombies table
        love.graphics.draw(sprites.zombie, z.x, z.y)
    end
end

function faceMouse() -- Returns the radian value needed for the player sprite to face the mouse
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function spawnZombie() -- Function to create zombies
    local zombie = {} -- Creates a local table to hold the zombie info
    zombie.x = 300 -- Sets the zombie x coord
    zombie.y = 500 -- Sets the zombie y coord
    zombie.speed = 100 -- Sets the zombie speed
    table.insert(zombies, zombie) -- Inserts this table into the zombies table in the love.load()
end