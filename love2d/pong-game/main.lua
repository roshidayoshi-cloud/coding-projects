function love.load()
    love.window.setTitle("Pong Survival - Advanced")
    
    gameState = "menu"  -- menu, play, gameover, settings, challengeSetup
    
    -- Color settings
    ballColor = {1, 1, 1}  -- white
    backgroundColor = {0.1, 0.1, 0.1}  -- dark
    
    -- Challenge mode
    numBalls = 1
    
    -- Visual feedback
    hitFlash = 0
    
    -- Paddle
    paddle = {
        x = 650,
        y = 300,
        width = 20,
        height = 100,
        speed = 350,
        baseHeight = 100
    }
    
    -- Balls table
    balls = {}
    initializeBalls()
    
    score = 0
    hits = 0
    combo = 0
    powerups = {}
    downgrades = {}
end

function initializeBalls()
    balls = {}
    for i = 1, numBalls do
        table.insert(balls, {
            x = 200 + (i - 1) * 60,
            y = 200 + (i - 1) * 60,
            width = 15,
            height = 15,
            speedX = 300 + (i - 1) * 40,
            speedY = 300 + (i - 1) * 40,
            baseSpeed = 300 + (i - 1) * 40
        })
    end
end

function love.update(dt)
    -- Flash decay
    if hitFlash > 0 then
        hitFlash = hitFlash - dt
    end
    
    if gameState == "play" then
        -- Move paddle with smooth acceleration
        if love.keyboard.isDown("w") and paddle.y > 0 then
            paddle.y = paddle.y - paddle.speed * dt
        end
        if love.keyboard.isDown("s") and paddle.y < 600 - paddle.height then
            paddle.y = paddle.y + paddle.speed * dt
        end
        
        -- Update all balls
        for ballIdx, ball in ipairs(balls) do
            -- Move ball
            ball.x = ball.x + ball.speedX * dt
            ball.y = ball.y + ball.speedY * dt
            
            -- Ball bounces off top/bottom
            if ball.y < 0 then
                ball.y = 0
                ball.speedY = -ball.speedY
            elseif ball.y > 600 - ball.height then
                ball.y = 600 - ball.height
                ball.speedY = -ball.speedY
            end
            
            -- Ball bounces off left wall (FIXED)
            if ball.x < 0 then
                ball.x = 0
                ball.speedX = -ball.speedX
            end
            
            -- Ball bounces off paddle
            if ball.x + ball.width > paddle.x and
               ball.x < paddle.x + paddle.width and
               ball.y + ball.height > paddle.y and
               ball.y < paddle.y + paddle.height then
                
                -- Push ball out of paddle
                ball.x = paddle.x - ball.width
                ball.speedX = -ball.speedX
                
                -- Add spin based on where it hits paddle
                local hitPos = (ball.y - paddle.y) / paddle.height
                ball.speedY = ball.baseSpeed * (hitPos - 0.5) * 2
                
                -- Score and combo
                hits = hits + 1
                combo = combo + 1
                score = score + (10 * combo)
                hitFlash = 0.1
                
                -- Increase speed every 5 hits
                if hits % 5 == 0 then
                    ball.baseSpeed = ball.baseSpeed + 40
                    if ball.speedX > 0 then
                        ball.speedX = ball.baseSpeed
                    else
                        ball.speedX = -ball.baseSpeed
                    end
                end
                
                -- Spawn power-up randomly
                if math.random() < 0.15 then
                    table.insert(powerups, {x = ball.x, y = ball.y, width = 20, height = 20})
                end
                
                -- Spawn downgrade randomly
                if math.random() < 0.4 then
                    table.insert(downgrades, {x = ball.x, y = ball.y, width = 20, height = 20})
                end
            end
            
            -- Check if ball escapes
            if ball.x > 800 then
                gameState = "gameover"
            end
        end
        
        -- Update powerups
        for i = #powerups, 1, -1 do
            local pu = powerups[i]
            pu.y = pu.y + 200 * dt
            
            -- Check collision with paddle
            if pu.x + pu.width > paddle.x and
               pu.x < paddle.x + paddle.width and
               pu.y + pu.height > paddle.y and
               pu.y < paddle.y + paddle.height then
                paddle.height = math.min(200, paddle.height + 25)
                score = score + 50
                table.remove(powerups, i)
            elseif pu.y > 800 then
                table.remove(powerups, i)
            end
        end
        
        -- Update downgrades
        for i = #downgrades, 1, -1 do
            local dg = downgrades[i]
            dg.y = dg.y + 200 * dt
            
            -- Check collision with paddle
            if dg.x + dg.width > paddle.x and
               dg.x < paddle.x + paddle.width and
               dg.y + dg.height > paddle.y and
               dg.y < paddle.y + paddle.height then
                paddle.height = math.max(30, paddle.height - 25)
                score = math.max(0, score - 25)
                combo = 0
                table.remove(downgrades, i)
            elseif dg.y > 800 then
                table.remove(downgrades, i)
            end
        end
    end
end

function drawStar(x, y, size)
    local points = {}
    for i = 0, 9 do
        local angle = (i * math.pi) / 5
        local radius = i % 2 == 0 and size or (size * 0.4)
        table.insert(points, x + radius * math.cos(angle - math.pi / 2))
        table.insert(points, y + radius * math.sin(angle - math.pi / 2))
    end
    love.graphics.polygon("fill", points)
end

function drawDownArrow(x, y, size)
    love.graphics.polygon("fill", 
        x, y,
        x + size, y,
        x + size / 2, y + size
    )
end

function love.draw()
    love.graphics.clear(backgroundColor[1], backgroundColor[2], backgroundColor[3])
    
    if gameState == "menu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(48))
        love.graphics.printf("PONG SURVIVAL", 0, 80, 800, "center")
        
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("Press 1 - Normal Mode", 0, 200, 800, "center")
        love.graphics.printf("Press 2 - Challenge Mode", 0, 250, 800, "center")
        love.graphics.printf("Press 3 - Settings", 0, 300, 800, "center")
        love.graphics.printf("Press Q - Quit", 0, 350, 800, "center")
        
    elseif gameState == "challengeSetup" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("CHALLENGE MODE", 0, 80, 800, "center")
        
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("Select Number of Balls:", 0, 180, 800, "center")
        
        love.graphics.printf("Press 1 - 1 Ball (Easy)", 0, 250, 800, "center")
        love.graphics.printf("Press 2 - 2 Balls (Medium)", 0, 300, 800, "center")
        love.graphics.printf("Press 3 - 3 Balls (Hard)", 0, 350, 800, "center")
        love.graphics.printf("Press M - Back to Menu", 0, 450, 800, "center")
        
    elseif gameState == "settings" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.printf("SETTINGS", 0, 30, 800, "center")
        
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf("Ball Color: Press 1-White  2-Red  3-Green  4-Blue", 30, 120, 740, "left")
        
        love.graphics.printf("Background: Press 5-Dark  6-Blue  7-Purple", 30, 170, 740, "left")
        
        love.graphics.printf("Current Ball: ", 30, 240, 200, "left")
        love.graphics.setColor(ballColor[1], ballColor[2], ballColor[3])
        love.graphics.rectangle("fill", 200, 235, 50, 30)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Current Background: ", 30, 300, 200, "left")
        love.graphics.setColor(backgroundColor[1], backgroundColor[2], backgroundColor[3])
        love.graphics.rectangle("fill", 200, 295, 50, 30)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press M - Back to Menu", 30, 400, 740, "left")
        
    elseif gameState == "play" or gameState == "gameover" then
        -- Draw paddle
        love.graphics.setColor(1, 0, 1)
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)
        
        -- Draw balls with glow on hit
        if hitFlash > 0 then
            love.graphics.setColor(ballColor[1], ballColor[2], ballColor[3], 0.5)
            for _, ball in ipairs(balls) do
                love.graphics.rectangle("fill", ball.x - 5, ball.y - 5, ball.width + 10, ball.height + 10)
            end
        end
        
        love.graphics.setColor(ballColor[1], ballColor[2], ballColor[3])
        for _, ball in ipairs(balls) do
            love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
        end
        
        -- Draw powerups as stars
        love.graphics.setColor(0, 1, 0)
        for _, pu in ipairs(powerups) do
            drawStar(pu.x + 10, pu.y + 10, 10)
        end
        
        -- Draw downgrades as arrows
        love.graphics.setColor(1, 0, 0)
        for _, dg in ipairs(downgrades) do
            drawDownArrow(dg.x + 5, dg.y + 5, 15)
        end
        
        -- Draw UI
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print("W/S to move | Q to quit", 10, 10)
        
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.print("Score: " .. score, 300, 10)
        love.graphics.print("Combo: " .. combo, 550, 10)
        
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print("Hits: " .. hits, 300, 35)
        love.graphics.print("Balls: " .. numBalls, 550, 35)
        
        if gameState == "gameover" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, 800, 600)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(love.graphics.newFont(56))
            love.graphics.printf("GAME OVER", 0, 100, 800, "center")
            
            love.graphics.setFont(love.graphics.newFont(28))
            love.graphics.printf("Final Score: " .. score, 0, 200, 800, "center")
            love.graphics.printf("Hits: " .. hits, 0, 250, 800, "center")
            love.graphics.printf("Max Combo: " .. combo, 0, 300, 800, "center")
            
            love.graphics.setFont(love.graphics.newFont(20))
            love.graphics.printf("Press SPACE to return to menu", 0, 420, 800, "center")
        end
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "1" then
            numBalls = 1
            initializeBalls()
            gameState = "play"
            score = 0
            hits = 0
            combo = 0
        elseif key == "2" then
            gameState = "challengeSetup"
        elseif key == "3" then
            gameState = "settings"
        elseif key == "q" then
            love.event.quit()
        end
        
    elseif gameState == "challengeSetup" then
        if key == "1" then
            numBalls = 1
            initializeBalls()
            gameState = "play"
            score = 0
            hits = 0
            combo = 0
        elseif key == "2" then
            numBalls = 2
            initializeBalls()
            gameState = "play"
            score = 0
            hits = 0
            combo = 0
        elseif key == "3" then
            numBalls = 3
            initializeBalls()
            gameState = "play"
            score = 0
            hits = 0
            combo = 0
        elseif key == "m" then
            gameState = "menu"
        end
        
    elseif gameState == "settings" then
        if key == "1" then
            ballColor = {1, 1, 1}
        elseif key == "2" then
            ballColor = {1, 0, 0}
        elseif key == "3" then
            ballColor = {0, 1, 0}
        elseif key == "4" then
            ballColor = {0, 0, 1}
        elseif key == "5" then
            backgroundColor = {0.1, 0.1, 0.1}
        elseif key == "6" then
            backgroundColor = {0, 0.2, 0.4}
        elseif key == "7" then
            backgroundColor = {0.3, 0, 0.4}
        elseif key == "m" then
            gameState = "menu"
        end
        
    elseif gameState == "play" then
        if key == "q" then
            love.event.quit()
        end
        
    elseif gameState == "gameover" then
        if key == "space" then
            gameState = "menu"
            paddle.width = 20
            paddle.height = 100
            paddle.y = 300
            numBalls = 1
            initializeBalls()
            score = 0
            hits = 0
            combo = 0
            powerups = {}
            downgrades = {}
        elseif key == "q" then
            love.event.quit()
        end
    end
end
