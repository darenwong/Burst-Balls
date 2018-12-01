function wall_coll(x1, y1, r1, a1, b1)
  thres = 3
  if x1 + r1 > 800 and a1 < 90*math.pi/180 then
    a1 = math.pi - a1
    x1 = x1 - thres
    b1 = b1 -1 
    
  elseif x1 + r1 > 800 and a1 < 360*math.pi/180 then
    a1 = 540*math.pi/180 - a1 
    x1 = x1 - thres
    b1 = b1 -1 
    
  elseif x1 <r1 and a1 > 180*math.pi/180 then
    a1 = 540*math.pi/180 - a1 
    x1 = x1 + thres
    b1 = b1 -1 
    
  elseif x1 < r1 and a1 <= 180*math.pi/180 then
    a1 = 180*math.pi/180 - a1 
    x1 = x1 + thres
    b1 = b1 -1 
    
  elseif y1 + r1 > 600 then
    a1 = 360*math.pi/180 - a1 
    y1 = y1 - thres
    b1 = b1 -1 
    
  elseif y1 < r1 then
    a1 = 360*math.pi/180 - a1 
    y1 = y1 + thres
    b1 = b1 -1 
  end
  
  return a1, b1, x1, y1
end



function ball_coll(x1, y1, r1, v1, a1, x2, y2, r2, v2, a2)
  
  if (x1 - x2)^2 + (y1 - y2)^2 <= (r1 + r2)^2 then
    
    v1_new = v1
    v2_new = v2
    a1_new = a1 + math.pi
    a2_new = a2 + math.pi
    
    if a1 > 2*math.pi then
      a1_new = a1_new - 2*math.pi
    end
    
    if a2 > 2*math.pi then
      a2_new = a2_new - 2*math.pi   
    end
    
  else
    v1_new = v1
    a1_new = a1
    v2_new = v2
    a2_new = a2
  end
  
  return v1_new, a1_new, v2_new, a2_new
end

function love.load()
  math.randomseed(os.time())
  reset = 0
  balls = {}
  bombs = {}
  score = 0  
  Lives = 500
  gameover = 0
end

function love.mousereleased(x, y, button)
  reset = 0 
  return reset
end

function love.update(dt)
  
  if #balls < 3 then
    if math.random() < 0.01 then
      local ball = {}
      ball.x = math.random(100, 700)
      ball.y = math.random(100, 500)
      ball.v = math.random(50,250)
      ball.r = 50*math.random(1,2)
      ball.a = math.random(0, 360)*math.pi/180
      ball.p = math.random(2, 9)
      ball.c = ball.r/100
      table.insert(balls, ball)
    end
  end
  
  if #bombs < 2 then
    if math.random() < 0.005 then
      local bomb = {}
      bomb.x = math.random(100, 700)
      bomb.y = math.random(100, 500)
      bomb.v = math.random(50,250)
      bomb.r = 25*math.random(1,4)
      bomb.a = math.random(0, 360)*math.pi/180
      bomb.p = math.random(2, 9)
      bomb.c = 1
      table.insert(bombs, bomb)
    end
  end

  
  
  for i=#bombs, 1, -1 do
    local bomb = bombs[i]
    --print(i, ball.v)
    bomb.a, bomb.p, bomb.x, bomb.y = wall_coll(bomb.x, bomb.y, bomb.r, bomb.a, bomb.p)
    
    if bomb.p <= 0 then
      table.remove(bombs, i)      
      break
    end
    
    bomb.x = bomb.x + bomb.v*dt*math.cos(bomb.a)
    bomb.y = bomb.y + bomb.v*dt*math.sin(bomb.a)
    bomb.v = bomb.v + 0.1
  end
  
  for i=#balls, 1, -1 do
    local ball = balls[i]
    --print(i, ball.v)
    ball.a, ball.p, ball.x, ball.y = wall_coll(ball.x, ball.y, ball.r, ball.a, ball.p)
    
    if ball.p <= 0 then
      table.remove(balls, i)
      Lives = Lives - 1
      
      if Lives <= 0 then
        gameover = 1
      end
      
      break
    end
    
    ball.x = ball.x + ball.v*dt*math.cos(ball.a)
    ball.y = ball.y + ball.v*dt*math.sin(ball.a)
    ball.v = ball.v + 0.1
    
  end
  
  
  if love.mouse.isDown(1) and reset == 0 then
    mouse_x, mouse_y = love.mouse.getPosition()
    reset = 1
    
    for i=#balls, 1, -1 do
      local ball = balls[i]    
      
      if mouse_x < ball.x + ball.r and mouse_x > ball.x - ball.r and mouse_y < ball.y + ball.r and mouse_y > ball.y - ball.r then
        x = ball.x
        y = ball.y
        r = ball.r
        table.remove(balls, i)
        
        if ball.r > 25 then
          n = math.random(2,3)
          for i=n, 1, -1 do
              local ball = {}
              ball.x = x 
              ball.y = y
              ball.v = math.random(50,200)
              ball.r = r/math.sqrt(2)
              ball.a = math.random(0, 360)*math.pi/180
              ball.p = math.random(5, 9)
              ball.c = ball.r/100
              table.insert(balls, ball)
            end
        else
          score = score  + 1
        end
        
        break
      end
    end
    
    for i=#bombs, 1, -1 do
      local bomb = bombs[i]    
      
      if mouse_x < bomb.x + bomb.r and mouse_x > bomb.x - bomb.r and mouse_y < bomb.y + bomb.r and mouse_y > bomb.y - bomb.r then
        
        table.remove(bombs, i)
        Lives = Lives - 1
      
        
        break
      end
    end
  
  end 
end

function love.draw()
  if gameover == 0 then  
    for i=1, #balls, 1 do
      
      local ball = balls[i]
      love.graphics.setColor(0, 1- ball.c, ball.c)
      love.graphics.circle('fill', ball.x, ball.y, ball.r)
      
      font = love.graphics.newFont(ball.r)
      love.graphics.setFont(font)
      love.graphics.setColor(1, 1, 0)
      love.graphics.printf(ball.p, ball.x-ball.r/2, ball.y-ball.r/2, ball.r, "center")
    end
    
    for i=1, #bombs, 1 do
      
      local bomb = bombs[i]
      love.graphics.setColor(bomb.c, 0 , 0)
      love.graphics.circle('fill', bomb.x, bomb.y, bomb.r)
      
      font = love.graphics.newFont(bomb.r)
      love.graphics.setFont(font)
      love.graphics.setColor(1, 1, 0)
      love.graphics.printf(bomb.p, bomb.x-bomb.r/2, bomb.y-bomb.r/2, bomb.r, "center")
    end
    
    font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0.5, 0) 
    love.graphics.print('SCORE: ' .. score, 20, 20)
    love.graphics.print('LIVES: ' .. Lives, 600-150, 20)
    
  else
    font = love.graphics.newFont(50)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0, 0) 
    love.graphics.print('GAME OVER', 600/2, 800/2)
  end
end



