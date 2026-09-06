function love.load()
    user = {
        x = 50,
        y = 50,
        health = 220
}
    end


function love.draw()
        love.graphics.circle("fill",user.x, user.y, 10, 10)
        love.graphics.print("health: " .. user.health,100,100)

        if user.health == 0 then 
                  love.graphics.print("dead asf",200,200)    
        end
end

function love.update(dt)
     if love.keyboard.isDown("right") then user.x = user.x + 10      
     
     end

     if user.x == 100 then user.health = user.health - 10
     
     end
     
     if love.keyboard.isDown("left") then user.x = user.x - 10
    
     end
end
