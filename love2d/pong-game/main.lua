function love.load()
    -- Game setup
    love.window.setTitle("Pong Game")
    
    -- Paddle
    paddle = {
        x = 650,
        y = 300,
        width = 20,
        height = 100,
        speed = 300
    }
    
    -- Ball
    ball = {
        x = 200,
        y = 300,
        width = 15,
        height = 15,
        speedX = 300,
        speedY = 300
    }
    
    score = 0
end

function love.update(dt)
    -- Move paddle with W/S keys
    if love.keyboard.isDown("w") and paddle.y > 0 then
        paddle.y = paddle.y - paddle.speed * dt
    end
    if love.keyboard.isDown("s") and paddle.y < 600 - paddle.height then
        paddle.y = paddle.y + paddle.speed * dt
    end
    
    -- Move ball
    ball.x = ball.x + ball.speedX * dt
    ball.y = ball.y + ball.speedY * dt
    
    -- Ball bounces off top/bottom
    if ball.y < 0 or ball.y > 600 - ball.height then
        ball.speedY = -ball.speedY
    end
    
    -- Ball bounces off paddle
    if ball.x + ball.width > paddle.x and
       ball.x < paddle.x + paddle.width and
       ball.y + ball.height > paddle.y and
       ball.y < paddle.y + paddle.height then
        ball.speedX = -ball.speedX
    end
    -- ball bounces off left wall
    if ball.x < 0 then
        ball.speedX = -ball.speedX
    end
    
    -- Reset if ball goes off screen
    if ball.x > 800 then
        score = score -1
        ball.x = 400
        ball.y = 300
        ball.speedX = 300
        ball.speedY = 300
    end
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    
    -- Draw paddle
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)
    
    -- Draw ball
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
    
    -- Draw text
    love.graphics.print("W/S to move | Q to quit", 10, 10)
    love.graphics.print("Score: " .. score, 350, 10)
end

function love.keypressed(key)
    if key == "q" then
        love.event.quit()
    end
end
