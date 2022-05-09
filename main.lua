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

    zombies = {} -- Table to store tables of zombie data

    bullets = {} -- Table to store tables of bullet data
end

function love.update(dt) -- Function to update the game loop
    if love.keyboard.isDown("d") then -- If the d key is pressed
        player.x = player.x + player.speed * dt -- Goes right at a constant speed per second
    end
    if love.keyboard.isDown("s") then -- If the s key is pressed
        player.y = player.y + player.speed * dt -- Goes down at a constant speed per second
    end
    if love.keyboard.isDown("a") then -- If the a key is pressed
        player.x = player.x - player.speed * dt -- Goes left at a constant speed per second
    end
    if love.keyboard.isDown("w") then -- If the w key is pressed
        player.y = player.y - player.speed * dt -- Goes up at a constant speed per second
    end

    for i,z in ipairs(zombies) do -- Loop through each item in the zombies table
        z.x = z.x + (math.cos(facePlayer(z)) * z.speed * dt) -- Find the angle which the zombie has to go and find the x coord through cos
        z.y = z.y + (math.sin(facePlayer(z)) * z.speed * dt) -- Find the angle which the zombie has to go and find the y coord through sin

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then -- If the zombie touches the player
            for i,z in ipairs(zombies) do -- Loop through each item in the zombies table again
                zombies[i] = nil -- Delete each zombie
            end
        end
    end

    for i,b in ipairs(bullets) do -- Loops through each
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end

    for i=#bullets, 1, -1 do -- Loops through each item in the bullets table but does it from the reverse direction
        local b = bullets[i] -- Creates a local variable to store 
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
            end
        end
    end

    for i=#zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end 

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end
end

function love.draw() -- Function to render graphics to the screen
    love.graphics.draw(sprites.background, 0, 0) -- Puts in the background

    love.graphics.draw(sprites.player, player.x, player.y, faceMouse(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2) -- Draws the player at the player's position

    for i,z in ipairs(zombies) do -- Loops through all zombies in the zombies table
        love.graphics.draw(sprites.zombie, z.x, z.y, facePlayer(z), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end

    for i,b in ipairs(bullets) do -- Loops through all bullets in the bullets table
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2)
    end
end

function faceMouse() -- Returns the radian value needed for the player sprite to face the mouse
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x) -- Equation to find the angle between the two points
end

function facePlayer(enemy) -- Returns the radian value needed for the zombie sprite to face the player sprite
    return math.atan2(player.y - enemy.y, player.x - enemy.x) -- Equation to find the angle between the two points
end

function distanceBetween(x1, y1, x2, y2) -- Returns the distance between two objects
    return math.sqrt((x2-x1)^2 + (y2-y1)^2) -- Returns distance formula answer
end

function spawnZombie() -- Function to create zombies
    local zombie = {} -- Creates a local table to hold the zombie info
    zombie.x = math.random(0, love.graphics.getWidth()) -- Sets the zombie x coord
    zombie.y = math.random(0, love.graphics.getHeight()) -- Sets the zombie y coord
    zombie.speed = 140 -- Sets the zombie speed
    zombie.dead = false
    table.insert(zombies, zombie) -- Inserts this local zombie into the main zombies table
end

function spawnBullet() -- Function to create bullets
    local bullet = {} -- Creates a local table to hold bullet info
    bullet.x = player.x -- Bullet spawns at player's x coord
    bullet.y = player.y -- Bullet spawns at player's y coord
    bullet.speed = 500 -- Sets how fast the bullet goes
    bullet.direction = faceMouse() -- Travels towards the direction of the mouse
    bullet.dead = false
    table.insert(bullets, bullet) -- Inserts this local bullet table into the main bullets table
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button) -- Function to spawn in bullets
    if button == 1 then -- If primary button is clicked
        spawnBullet() -- Spawn a bullet
    end
end