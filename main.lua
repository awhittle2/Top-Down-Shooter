function love.load() -- Function to execute before the game loads
    math.randomseed(os.time()) -- Sets the random seed to be based on the time, so it will always be truly random

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

    myFont = love.graphics.newFont(30) -- Creates a new font of size 30

    gameState = 1 -- Tracks the game state
    maxTime = 2 -- Tracks the max time for the timer
    timer = maxTime -- Tracks how long till the next zombie spawns
    score = 0 -- Tracks the player score
end

function love.update(dt) -- Function to update the game loop
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then -- If the d key is pressed
            player.x = player.x + player.speed * dt -- Goes right at a constant speed per second
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then -- If the s key is pressed
            player.y = player.y + player.speed * dt -- Goes down at a constant speed per second
        end
        if love.keyboard.isDown("a") and player.x > 0 then -- If the a key is pressed
            player.x = player.x - player.speed * dt -- Goes left at a constant speed per second
        end
        if love.keyboard.isDown("w") and player.y > 0 then -- If the w key is pressed
            player.y = player.y - player.speed * dt -- Goes up at a constant speed per second
        end
    end

    for i,z in ipairs(zombies) do -- Loop through each item in the zombies table
        z.x = z.x + (math.cos(facePlayer(z)) * z.speed * dt) -- Find the angle which the zombie has to go and find the x coord through cos
        z.y = z.y + (math.sin(facePlayer(z)) * z.speed * dt) -- Find the angle which the zombie has to go and find the y coord through sin

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then -- If the zombie touches the player
            for i,z in ipairs(zombies) do -- Loop through each item in the zombies table again
                zombies[i] = nil -- Delete each zombie
                gameState = 1 -- Sets the game back to the main menu
                player.x = love.graphics.getWidth() / 2 -- Resets the x coord of the player to the center
                player.y = love.graphics.getHeight() / 2 -- Resets the y coord of the player to the center
            end
        end
    end

    for i,b in ipairs(bullets) do -- Loops through each item in the bullets table
        b.x = b.x + (math.cos(b.direction) * b.speed * dt) -- Updates its x to the cos of the direction its traveling at a constant speed per second
        b.y = b.y + (math.sin(b.direction) * b.speed * dt) -- Updates its y to the sin of the direction its traveling at a constant speed per second
    end

    for i=#bullets, 1, -1 do -- Loops through each item in the bullets table but does it from the reverse direction
        local b = bullets[i] -- Creates a local variable to store the current bullet
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then -- If the bullet is outside of the viewport
            table.remove(bullets, i) -- Remove the current bullet from the bullets table
        end
    end

    for i,z in ipairs(zombies) do -- Loops through all items in zombies table
        for j,b in ipairs(bullets) do -- Loops through all items in bullets table
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then -- If the distance is close enough (aka if they collide)
                z.dead = true -- Make the zombie die
                b.dead = true -- Make the bullet die
                score = score + 1 -- Adds 1 to the score
            end
        end
    end

    for i=#zombies, 1, -1 do -- Loops through all items in the zombies table in reverse order
        local z = zombies[i] -- Creates a local variable to store the current zombie
        if z.dead == true then -- If the zombie is dead
            table.remove(zombies, i) -- Remove it from the zombies table
        end
    end 

    for i=#bullets, 1, -1 do -- Loops through all items in the bullets table in reverse order
        local b = bullets[i] -- Creates a local variable to store the current bullet
        if b.dead == true then -- If the bullet is dead
            table.remove(bullets, i) -- Remove it from the bullets table
        end
    end

    if gameState == 2 then -- If the player is in the game
        timer = timer - dt -- Make the timer count down
        if timer <= 0 then -- If the timer reaches 0
            spawnZombie() -- Spawn a zombie
            maxTime = 0.95 * maxTime -- Decrease the max time by 5%
            timer = maxTime -- Reset the timer
        end
    end
end

function love.draw() -- Function to render graphics to the screen
    love.graphics.draw(sprites.background, 0, 0) -- Puts in the background

    if gameState == 1 then -- If the player is in the main menu
        love.graphics.setFont(myFont) -- Set teh font
        love.graphics.printf("Click Anywhere to Begin!", 0, 50, love.graphics.getWidth(), "center") -- Print text telling the user what to do
    end

    love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center") -- Print the score to the bottom center of the screen

    love.graphics.draw(sprites.player, player.x, player.y, faceMouse(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2) -- Draws the player at their x and y coordinates, make it face the mouse, and center the sprite

    for i,z in ipairs(zombies) do -- Loops through all zombies in the zombies table
        love.graphics.draw(sprites.zombie, z.x, z.y, facePlayer(z), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2) -- Draws the zombie at its x and y coordinates, make it face the player, and center the sprite
    end

    for i,b in ipairs(bullets) do -- Loops through all bullets in the bullets table
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2) -- Draws the bullet at its x and y coordinates, scales the sprite down, and centers it
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

    zombie.x = 0 -- Sets the zombie x coord
    zombie.y = 0 -- Sets the zombie y coord
    zombie.speed = 140 -- Sets the zombie speed
    zombie.dead = false -- Sets the zombie to be alive

    local side = math.random(1, 4) -- Creates a variable, to store a random number 1-4 which represents each side of the viewport
    if side == 1 then -- If its the left side
        zombie.x = -30 -- Set the zombie's x barely outside of the viewport
        zombie.y = math.random(0, love.graphics.getHeight()) -- Set its y coord to a random number
    elseif side == 2 then -- If its the right side
        zombie.x = love.graphics.getWidth() + 30 -- Set the zombie's x barely outside of the viewport
        zombie.y = math.random(0, love.graphics.getHeight()) -- Set its y coord to a random number
    elseif side == 3 then -- If its the top side
        zombie.x = math.random(0, love.graphics.getWidth()) -- Set its x coord to a random number
        zombie.y = -30 -- Set the zombie's y barely outside of the viewport
    else -- If its the bottom side
        zombie.x = math.random(0, love.graphics.getWidth()) -- Set its x coord to a random number
        zombie.y = love.graphics.getHeight() + 30 -- Set the zombie's y barely outside of the viewport
    end

    table.insert(zombies, zombie) -- Inserts this local zombie into the main zombies table
end

function spawnBullet() -- Function to create bullets
    local bullet = {} -- Creates a local table to hold bullet info
    bullet.x = player.x -- Bullet spawns at player's x coord
    bullet.y = player.y -- Bullet spawns at player's y coord
    bullet.speed = 500 -- Sets how fast the bullet goes
    bullet.direction = faceMouse() -- Travels towards the direction of the mouse
    bullet.dead = false -- Sets the bullet to be alive
    table.insert(bullets, bullet) -- Inserts this local bullet table into the main bullets table
end

function love.mousepressed(x, y, button) -- Function to spawn in bullets
    if button == 1 and gameState == 2 then -- If primary button is clicked and player is in the game
        spawnBullet() -- Spawn a bullet
    elseif button == 1 and gameState == 1 then -- If primary button is clicked and player is in the main menu
        gameState = 2 -- Set the player to the game
        maxTime = 2 -- Reset the max time
        timer = maxTime -- Reset the timer
        score = 0 -- Reset the score
    end
end